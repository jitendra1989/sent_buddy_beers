require 'test_helper'

class BarTest < ActiveSupport::TestCase
  setup do
    country = Factory(:country)
    city = Factory(:city, :country => country)
    @bar = Factory.build(:bar, :country => country, :city => city)
    @bar.prices_attributes = [Factory.attributes_for(:price)]
  end

  should belong_to(:affiliate)
  should belong_to(:country)
  should belong_to(:city)
  should belong_to(:bro)
  should have_one(:gallery)
  should have_many(:ious)
  should have_many(:prices)
  should have_many(:voucher_lists)
  should have_many(:line_items)
  should have_many(:translations)
  should have_many(:beers).through(:prices)
  should have_many(:payout_models)
  should have_many(:sites).through(:bar_sites)
  should have_many(:employments).dependent(:destroy)
  should have_many(:employees).through(:employments)

  should validate_presence_of(:name)
  should validate_presence_of(:address)
  should validate_presence_of(:country_id)
  should validate_presence_of(:city_id)
  should validate_presence_of(:percent_cut)
  should validate_presence_of(:percent_expired_cut)
  should validate_presence_of(:customer_voucher_limit)
  should validate_numericality_of(:percent_cut)
  should validate_numericality_of(:percent_expired_cut)
  
  should have_attached_file(:logo)

  context "An inactive bar" do
    setup { @bar.active = false }

    should validate_presence_of(:contact_email)
    should validate_presence_of(:contact_phone_number)
    should validate_presence_of(:contact_name)
    should_not allow_value("a bc").for(:contact_email)
    should_not allow_value("abc").for(:contact_email)
    should_not allow_value("abc@").for(:contact_email)
    should_not allow_value("abc.com").for(:contact_email)
    should_not allow_value("wrong@email").for(:contact_email)
    should allow_value("abc@abc.com").for(:contact_email)

    should "check if bar is inactive" do
      assert @bar.inactive?
    end
    
    should "not send and email when passed #send_redeemed_voucher_report!" do
      @email_count = ActionMailer::Base.deliveries.length
      @bar.send_redeemed_voucher_report!
      assert_equal @email_count, ActionMailer::Base.deliveries.length
    end
  end
  
  context "a bar with whitespace in the name" do
    setup do 
      @bar.name = "   White Out Bar   " 
      @bar.save
    end
    
    should "have the whitespace stripped" do
      assert_equal @bar.name, "White Out Bar"
    end
  end

  context "A new bar" do
    context "that is saved" do
      setup { @bar.save }
    
      should "automatically generate a 4 digit token" do
        assert_equal 4, @bar.try(:token).try(:length), "prices: #{@bar.prices.inspect} prices_attributes: #{Factory.attributes_for(:price)}"
      end

      should "be geocoded" do
        assert @bar.geocoded?
      end
      
      should "not create a delayed job" do
        assert_equal 0, Delayed::Job.count
      end
      
      should "have a gallery" do
        assert @bar.gallery(true).present?
      end

      should "have a friendly_id which matches the name city and country" do
        assert @bar.friendly_id == @bar.name_city_and_country.gsub(" ", "-").downcase
      end
      
      should "also reference friendly_id by slug" do
        assert_equal @bar.slug, @bar.name_city_and_country.gsub(" ", "-").downcase
      end
      
      should "be able to be found by it's friendly id" do
        assert_equal @bar, Bar.find(@bar.name_city_and_country.gsub(" ", "-").downcase)
      end

      should "have a payout model" do
        assert !@bar.payout_models.blank?
      end

      should "be associated with the default site" do
        assert Site.default.bars.include?(@bar)
      end
    end

    context "with an ill-formatted url" do
      setup { @bar.url = "example.com" }
      
      should "have http:// automatically prepended to it's url when saved" do
        @bar.save!
        assert @bar.url.starts_with?("http://")
      end
    end

    context "with an ill-formatted twitter handle" do
      setup { @bar.twitter_handle = "http://www.twitter.com/newbar" }
      
      should "have stripped the url from the twitter handle when saved" do
        @bar.save!
        assert_equal "newbar", @bar.twitter_handle
      end
    end
    
    context "with a description" do
      setup do 
        @bar.description = "Is the greatest!"
        @bar_translation_count = BarTranslation.count
        @bar.save!
      end
      
      should "increase the translation count" do
        assert_equal 1, BarTranslation.count(true) - @bar_translation_count 
      end  
    end
  end

  context "An active bar" do
    setup do
      @bar.active = true
    end

    should "calculate drinks sold" do
      assert_not_nil @bar.drinks_sold
      assert @bar.drinks_sold.is_a?(Integer)
    end

    should "calculate drinks redeemed" do
      assert_not_nil @bar.drinks_redeemed
      assert @bar.drinks_redeemed.is_a?(Integer)
    end

    should "have profit" do
      assert_not_nil @bar.profit
      assert @bar.profit.is_a?(Money)
    end

    should "have turnover" do
      assert_not_nil @bar.turnover
      assert @bar.turnover.is_a?(String)
    end

    should "have a full address" do
      assert_not_nil @bar.full_address
    end
    
    # removing this for now to reduce headaches -tjt
    # not entirely necessary
    # context "with no prices" do
    #       setup { @bar.prices = [] }
    #       
    #       should "be invalid" do
    #         assert !@bar.valid?
    #       end
    #     end
    #     
    #     context "with at least one price" do
    #       setup { @bar.prices.new(Factory.attributes_for(:price))}
    #       
    #       should "be valid" do
    #         assert @bar.valid?
    #       end
    #       
    #       should "have prices" do
    #         assert @bar.prices.present?
    #       end
    #     end
    
    context "with an employee" do
      setup do
        @employee = Factory(:user)
        Factory(:employment, :bar => @bar, :user => @employee)
      end
      
      should "return true when passed employs? and the user object" do
        assert @bar.employs?(@employee)
      end
      
      should "return true when passed employs? and the affilaite object" do
        assert @bar.employs?(@bar.affiliate)
      end
      
      should "return true when passed employs? and the affilaite object" do
        assert @bar.employs?(Factory(:admin))
      end
    end
    
    should "not send an email when passed #send_redeemed_voucher_report!" do
      @email_count = ActionMailer::Base.deliveries.length
      @bar.send_redeemed_voucher_report!
      assert_equal @email_count, ActionMailer::Base.deliveries.length
    end
    
    context "with some redeemed vouchers" do
      setup do
        @iou = Factory(:iou, :quantity => 10)
        @iou.paid!
        @iou.vouchers.first(3).each { |v| v.update_attributes(:redeemed => true, :redeemed_at => 1.month.ago.beginning_of_day + 2.hours) }
        @iou.vouchers.first(6).last(3).each { |v| v.update_attributes(:redeemed => true, :redeemed_at => 1.week.ago.beginning_of_day + 2.hours) }
        @iou.vouchers.last(4).each { |v| v.update_attributes(:redeemed => true, :redeemed_at => 1.day.ago.beginning_of_day + 2.hours) }
        @email_count = ActionMailer::Base.deliveries.length
      end
      
      context "and the redeemed_voucher_notification_timeframe set to never" do
        setup { @iou.bar.update_attribute(:redeemed_voucher_notification_timeframe, "never") }
      
        should "not send an email when passed #send_redeemed_voucher_report!" do
          @iou.bar.send_redeemed_voucher_report!
          assert_equal @email_count, ActionMailer::Base.deliveries.length
        end
      end
      
      context "and the redeemed_voucher_notification_timeframe set to daily" do
        setup { @iou.bar.update_attribute(:redeemed_voucher_notification_timeframe, "daily") }
      
        should "send an email when passed #send_redeemed_voucher_report!" do
          @iou.bar.send_redeemed_voucher_report!
          assert_equal 1, ActionMailer::Base.deliveries.length - @email_count
        end
      end
      
      context "and the redeemed_voucher_notification_timeframe set to weekly" do
        setup { @iou.bar.update_attribute(:redeemed_voucher_notification_timeframe, "weekly") }
      
        should "send an email when passed #send_redeemed_voucher_report!" do
          @iou.bar.send_redeemed_voucher_report!
          assert_equal 1, ActionMailer::Base.deliveries.length - @email_count
        end
      end
      
      context "and the redeemed_voucher_notification_timeframe set to monthly" do
        setup { @iou.bar.update_attribute(:redeemed_voucher_notification_timeframe, "monthly") }
      
        should "send an email when passed #send_redeemed_voucher_report!" do
          @iou.bar.send_redeemed_voucher_report!
          assert_equal 1, ActionMailer::Base.deliveries.length - @email_count
        end
      end
    end
  end

  should "return only bars associated with given site on #for_site" do
    site_1 = Factory(:site, :name => "Tyskie")
    site_2 = Factory(:site, :name => "Lech")
    
    @bar.sites << site_1
    @bar.save
    
    assert Bar.for_site(site_1).include?(@bar)
    assert !Bar.for_site(site_2).include?(@bar)
  end

  should "always be associated with default site" do
    @bar.sites = []
    @bar.save!
    assert @bar.sites.include?(Site.default)
  end

  context "scopes" do
    should "not return same records when site admin manages same bar through few sites" do
      site = Factory(:site)
      @bar.sites << site
      @bar.save
      site_admin = Factory(:site_admin, :sites => [Site.default, site])
      assert_equal [@bar], Bar.for_site_admin(site_admin).all
    end
  end
end
