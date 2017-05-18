require 'test_helper'

class IouTest < ActiveSupport::TestCase
  should belong_to(:beverage)
  should belong_to(:brand)
  should belong_to(:beer)
  should belong_to(:bar)
  should belong_to(:price)
  should belong_to(:site)
  should have_many(:line_items)
  should have_one(:credit_event)

  should validate_presence_of(:status)
  should validate_presence_of(:sender_id)
  should validate_presence_of(:bar_id).with_message("must be chosen")
  should validate_presence_of(:price_id).with_message("must be chosen")
  should validate_presence_of(:site)
  should validate_presence_of(:quantity).with_message("must be chosen")

  should_not allow_value("a bc").for(:recipient_email)
  should_not allow_value("abc").for(:recipient_email)
  should_not allow_value("abc@").for(:recipient_email)
  should_not allow_value("abc.com").for(:recipient_email)
  should_not allow_value("wrong@email").for(:recipient_email)
  should_not allow_value("123").for(:recipient_phone)
  should allow_value("abc@abc.com").for(:recipient_email)
  should allow_value("1234567").for(:recipient_phone)
  #before validation hook should strip dashes, dots, etc.
  should allow_value("123-4567").for(:recipient_phone)
  should allow_value("(123) 4567").for(:recipient_phone)
  should allow_value("(123) 456-7333").for(:recipient_phone)
  should allow_value("123.456.7333").for(:recipient_phone)
  

  # discountable concern tests
  context "an unsaved iou" do

    setup { @iou = Factory.build(:iou) }

    should "have a total as a money object" do
      assert @iou.total.present?
      assert @iou.total.is_a?(Money)
    end

    should "return false for :discounted?" do
      assert !@iou.discounted?
      assert_equal @iou.discounted?, @iou.discounted
    end

    context "with a discounted amount" do
      setup do
        @iou.cents = 200
        @iou.discounted = true
        @iou.discounted_cents = 100
      end

      should "return the discounted cents as total" do
        assert_equal 100, @iou.total.cents
      end

      should "claim vouchers on #paid!" do
        @iou.quantity = 5
        assert_difference("@iou.bar.vouchers.available.count", -5) do
          @iou.paid!
        end
      end
      
      should "claim the exact amount of vouchers on #paid!" do
        @iou.quantity = 5
        @iou.paid!
        assert_equal 5, @iou.vouchers.length
      end
    end

    context "without a amount" do
      setup { @iou.cents = nil }
      should "still save because it's calculated from the iou's price" do
        assert_difference "Iou.count" do
          @iou.save
          assert !@iou.new_record?
          assert @iou.errors.empty?
        end
      end
    end

    context "with a amount of zero" do
      setup { @iou.cents = 0 }
      should "still save because it's calculated from the iou's price" do
        assert_difference "Iou.count" do
          @iou.save
          assert !@iou.new_record?
          assert @iou.errors.empty?
        end
      end
    end

    context "with a discounted amount of zero and discounted set to true" do
      setup do
        @iou.discounted_cents = 0
        @iou.discounted = true
      end
      should "still save because it's calculated from the iou's price" do
        assert_difference "Iou.count" do
          @iou.save
          assert !@iou.new_record?
          assert @iou.errors.empty?
        end
      end
    end

    context "with a discounted amount more than it's regular amount" do
      setup do
        @iou.discounted_cents = 1000
        @iou.discounted = true
      end
      should "still save because it's calculated from the iou's price" do
        assert_difference "Iou.count" do
          @iou.save
          assert !@iou.new_record?
          assert @iou.errors.empty?
        end
      end
    end

    context "sending amount, not cents" do
      setup do
        @iou.cents = nil
        @iou.amount = "2.00"
      end

      should "still save and have the amount caluculated from it's price" do
        assert_difference "Iou.count" do
          @iou.save
          assert !@iou.new_record?
          assert @iou.errors.blank?
          assert_equal 200, @iou.cents
        end
      end
    end

  end
  # end discountable concern tests

  context "A new iou" do
    setup do
      @iou = Factory(:iou)
    end

    should "automatically store the price in cents" do
      assert_not_nil @iou.cents
      assert_equal @iou.cents, @iou.bar.prices.find(@iou.price_id).amount.cents * @iou.quantity
    end

    should "automatically generate a 10 digit token for all vouchers" do
      @iou.vouchers.all.each do |voucher|
        assert_not_nil voucher.token
        assert_equal voucher.token.length, 10
      end
    end
    
    should "generate a token" do
      assert @iou.token.present?
      assert_equal @iou.token.length, 6
    end

    should "have a total that is a Money object" do
      assert_not_nil @iou.total
      assert @iou.total.is_a?(Money)
    end

    should "have a currency as a string" do
      assert_not_nil @iou.currency
      assert @iou.currency.is_a?(String)
    end
    
    should "have a price in buddy bucks" do
      assert_equal @iou.price_in_bucks, @iou.cents
    end

    should "automatically add the price, price name and bar name" do
      assert_nil @iou.beer
      assert_nil @iou.brand_name
      assert_nil @iou.beer_name
      assert_not_nil @iou.bar_name
      assert_nil @iou.beverage_name
      assert_not_nil @iou.price
      assert_not_nil @iou.price_name
      assert @iou.discounted_cents.present?
      assert_false @iou.discounted
      assert_equal @iou.discounted_cents, @iou.price.discounted_cents
      assert_equal @iou.discounted, @iou.price.discounted
    end
    
    context "with a price that has a beer and brand" do
      setup do
        @iou.price = Factory(:price, :beer => Factory(:beer, :brand => Factory(:brand)))
        @iou.save
      end
      
      should "automatically add the beer, price, brand name, beer name, bar name, beverage name" do
        assert_not_nil @iou.beer
        assert_not_nil @iou.brand_name
        assert_not_nil @iou.beer_name
        assert_not_nil @iou.bar_name
        assert_not_nil @iou.beverage_name
        assert_not_nil @iou.price
        assert_not_nil @iou.price_name
        assert @iou.discounted_cents.present?
        assert_false @iou.discounted
        assert_equal @iou.discounted_cents, @iou.price.discounted_cents
        assert_equal @iou.discounted, @iou.price.discounted
      end
    end

    context "that is paid" do
      setup do 
        @delayed_job_count = Delayed::Job.count
        @iou.paid!
      end

      should "have a voucher" do
        assert @iou.vouchers.present?
      end

      should "have a price that matches it's affiliated price" do
        assert_equal @iou.cents, @iou.price.cents
      end

      should "have a currency that matches it's affiliated currency" do
        assert_equal @iou.currency, @iou.price.currency
      end
      
      should "have a paid_at date" do
        assert_not_nil @iou.paid_at
      end
      
      should "have an expiration date" do
        assert_not_nil @iou.expires_at
      end
      
      should "have set 3 delayed jobs, one for expiration, and two reminders" do
        assert_equal 3, Delayed::Job.count - @delayed_job_count
      end
      
      # should "post to twitter" do
      #   assert @iou.post_to_twitter!
      # end
    end

  end

  # This tests the whole process of sending an iou just as you would in the new iou form
  context "A new iou with a discounted price" do
    setup do
      @delayed_job_count = Delayed::Job.count
      @discounted_price = Factory(:discounted_price)
      @iou = Factory(:iou, :price => @discounted_price)
    end

    should "be saved" do
      assert !@iou.new_record?
    end

    should "not have a beer" do
      assert_nil @iou.beer
    end

    should "not have a brand" do
      assert_nil @iou.brand
    end

    should "have a price" do
      assert_not_nil @iou.price
    end

    should "have a price that matches the full price" do
      assert_equal @discounted_price.cents, @iou.cents
    end
    
    should "have a price name" do
      assert_not_nil @iou.price_name
    end

    should "be discounted" do
      assert @iou.discounted?
    end

    context "and is then paid" do
      setup { @iou.paid! }

      should "have a voucher with the full price" do
        assert @iou.vouchers.present?
        assert_equal 1, @iou.vouchers.size
        assert_equal @discounted_price.cents, @iou.vouchers.first.cents
      end

      should "have a discounted price that matches the iou" do
        assert_equal @discounted_price.discounted_cents, @iou.vouchers.first.discounted_cents
        assert_equal true, @iou.vouchers.first.discounted, "!! #{@iou.inspect} #{@iou.vouchers.first.inspect} !!"
      end
      
      should "have set 3 delayed jobs, one for expiration, and two reminders" do
        assert_equal 3, Delayed::Job.count - @delayed_job_count
      end
    end
  end

  context "A new iou without a brand but with a beer" do
    setup do
      @iou = Factory(:iou, :brand_id => nil, :beer => Factory(:beer))
    end

    should "automatically add the brand" do
      assert_not_nil @iou.brand
    end

    should "be saved" do
      assert !@iou.new_record?
    end
  end

  context "A new iou without a beer" do
    setup do
      @iou = Factory(:iou, :beer_id => nil, :price => Factory(:price, :beer => Factory(:beer)))
    end

    should "automatically add the beer" do
      assert_not_nil @iou.beer, @iou.errors.full_messages
    end

    should "be saved" do
      assert !@iou.new_record?
    end
  end

  context "A new iou with an existing user's email" do
    setup do
      @user = Factory(:customer)
      @iou = Factory(:iou, :recipient_email => @user.emails.first.email)
    end

    should "automatically add the user as recipient" do
      assert_equal @user, @iou.recipient
    end
  end
  
  context "A new iou with an existing user's email that is camelcased" do
    setup do
      @user = Factory(:customer)
      @iou = Factory(:iou, :recipient_email => @user.emails.first.email.camelcase)
    end

    should "automatically add the user as recipient" do
      assert_equal @user, @iou.recipient
    end
  end

  context "A new iou with an existing user's phone number" do
    setup do
      @user = Factory(:customer, :phone_number => "491778793342")
      @iou = Factory(:iou, :recipient_phone => "491778793342")
    end

    should "automatically add the user as recipient" do
      assert_equal @user, @iou.recipient
    end
  end

  context "A new iou with an existing user" do
    setup do
      @user = Factory(:customer)
      @iou = Factory(:iou, :recipient_email => nil, :recipient => @user)
    end

    should "automatically add the user's a email" do
      assert_equal @user.emails.first.email, @iou.recipient_email
    end
  end

  context "An iou" do
    setup do
      @iou = Factory(:iou)
    end

    should "not have a valid status" do
      assert_equal @iou.status, "sent"
    end

    should "have an expiration date 6 months from today and no vouchers" do
      assert_not_nil @iou.expires_at
      assert_equal @iou.expires_at, 6.months.from_now.beginning_of_day
      assert @iou.vouchers.blank?
    end

    context "that is paid for" do
      setup do
        @iou.paid!
      end

      should "be marked as paid" do
        assert @iou.paid?
        assert_equal @iou.status, "valid"
        assert @iou.paid
        assert_not_nil @iou.paid_at
      end

      context "and is redeemed" do
        setup do
          @redeemed_iou = @iou
          @line_item_count = LineItem.count
          @redeemed_iou.redeem!
        end

        should "be marked as redeemed" do
          assert @redeemed_iou.status == "redeemed"
          assert @redeemed_iou.redeemed?
        end

        should "not be able to expire" do
          @redeemed_iou.expire!
          assert !@redeemed_iou.expired?
        end

        should "create line items (via vouchers model)" do
          assert_equal 1, LineItem.count - @line_item_count
        end
      end

      context "and expires" do
        setup do
          @expired_iou = @iou
          @line_item_count = LineItem.count
          @expired_iou.expire!
        end

        should "be marked as expired" do
          assert @expired_iou.expired?
        end

        should "create line items" do
          assert_equal 1, LineItem.count - @line_item_count
          assert @expired_iou.line_items.present?
        end
      end
    end
  end

  # Lets test what happens with promotional Ious
  # These are sent by the bar owners to promote their bar

  context "a promotional iou" do
    setup do
      @price = Factory(:price)
      @iou = Factory(:iou, :promotional => true, :price => @price, :bar => @price.bar)
      @iou.paid!
    end

    should "be valid, paid and promotional" do
      assert @iou.valid?
      assert @iou.paid
      assert @iou.promotional
    end

    should "have a voucher" do
      assert @iou.vouchers.present?
      assert_equal @iou.vouchers.size, 1
    end

    context "that is redeemed" do
      setup do
        @line_item_size = LineItem.all.size
        @iou.vouchers.each(&:redeem!)
      end

      should "have created one line item for the specific bar" do
        assert_equal 1, LineItem.all.size - @line_item_size
        assert @iou.bar.line_items.present?
        assert @iou.bar.line_items.size == 1
      end

      should "have a line item with no value" do
        assert @iou.bar.line_items.first.cents == 0
      end
    end
  end

  # Lets test what happens with company promotional Ious
  # These are sent by buddy beers as promotions

  context "a company promotional iou" do
    setup do
      @price = Factory(:price)
      @iou = Factory(:iou, :company_promotional => true, :price => @price, :bar => @price.bar)
      @iou.paid!
    end

    should "be valid, paid and company promotional" do
      assert @iou.valid?
      assert @iou.paid
      assert @iou.company_promotional
    end

    should "have a voucher" do
      assert @iou.vouchers.present?
      assert_equal @iou.vouchers.size, 1
    end

    context "that is redeemed" do
      setup do
        @line_item_size = LineItem.all.size
        @iou.vouchers.each(&:redeem!)
      end

      should "have created one line item for the specific bar" do
        assert_equal 1, LineItem.all.size - @line_item_size
        assert @iou.bar.line_items.present?
        assert @iou.bar.line_items.size == 1
      end

      should "have a line item with value" do
        assert @iou.bar.line_items.first.cents > 0
      end
    end
  end
  
  # New tests having to deal with SMS sending
  
  context "a new iou with an email" do
    setup do 
      @iou = Factory.build(:iou, :recipient_phone => nil)
    end
    
    should "be emailable" do
      assert @iou.emailable?
    end
    
    should "not be smsable" do
      assert !@iou.smsable?
    end
    
    should "be valid" do
      assert @iou.valid?, "#{@iou.recipient_phone.present?} :::::: #{@iou.inspect}"
    end
    
    context "that is nil and a phone number" do
      setup do 
        @iou.recipient_email = nil
        @iou.recipient_phone = "491778793342"
      end
    
      should "be smsable" do
        assert @iou.smsable?
      end
      
      should "be able to send an sms" do
        assert @iou.send_sms!
      end
      
      should "not be emailable" do
        assert !@iou.emailable?
      end
    
      should "be valid" do
        assert @iou.valid?
      end
    end
    
    context "that is nil but has a recipient" do
      setup do 
        @iou.recipient_email = nil
        @iou.recipient = Factory(:customer)
        @iou.recipient.emails << Factory(:email, :user => @iou.recipient)
      end
    
      should "not be smsable" do
        assert !@iou.smsable?
      end
      
      should "be emailable" do
        assert @iou.emailable?
      end
    
      should "not be valid" do
        assert @iou.valid?
      end
    end
    
    context "that is nil and with a nil phone number" do
      setup do
        @iou.recipient_email = @iou.recipient_phone = nil
      end
      
      should "not be smsable" do
        assert !@iou.smsable?
      end
      
      should "not be emailable" do
        assert !@iou.emailable?
      end
    
      should "not be valid" do
        assert !@iou.valid?
      end
    end
  end
  
  context "an iou with a phone number" do
    setup { @iou = Factory.build(:iou) }
    
    context "that has extra characters in it" do
      setup { @iou.recipient_phone = "(904) 302-7233" }
      
      should "be stripped on save" do
        @iou.save
        assert @iou.recipient_phone == 9043027233
      end
    end
    
    context "that has leading zeros" do
      setup { @iou.recipient_phone = "01779878989" }
      
      should "be stripped on save" do
        @iou.save
        assert @iou.recipient_phone == 1779878989
      end
    end
    
    context "with a country code" do
      setup do
        @iou.recipient_phone = "(904) 302-7233"
        @iou.recipient_phone_country_code = "1"
      end
      
      should "have it added to the phone number on save" do
        @iou.save
        assert @iou.recipient_phone == 19043027233
      end
    end
    
    context "that is blank but has a country code" do
      setup do
        @iou.recipient_phone = ""
        @iou.recipient_phone_country_code = "1"
        @iou.save
      end
      
      should "be blank" do
        assert @iou.recipient_phone.blank?
      end
      
      should "be valid" do
        assert @iou.valid?
      end
    end
  end
  

  # These are kind of duplicate tests but why not execute them? -tjt

  should "create an (unpaid) iou with no recipient" do
    assert_difference 'Iou.count' do
      iou = Factory(:iou)
      assert !iou.sender.blank?
      assert !iou.status.blank?
      assert !iou.recipient_email.blank?
      assert iou.recipient.blank?
      assert !iou.sender.blank?
      assert iou.beer.blank?
      assert iou.brand.blank?
      assert !iou.bar.blank?
      assert iou.beverage.blank?
      assert !iou.total.blank?
      assert_equal "sent", iou.status
      assert !iou.new_record?, "#{iou.errors.full_messages.to_sentence}"
    end
  end

  should "create an (unpaid) iou with an existing recipient" do
    assert_difference 'Iou.count' do
      user = Factory(:customer)
      iou = Factory(:iou, :recipient_email => user.emails.first.email)
      assert !iou.sender.blank?
      assert !iou.status.blank?
      assert !iou.recipient_email.blank?
      assert !iou.recipient.blank?
      assert !iou.sender.blank?
      assert iou.beer.blank?
      assert iou.brand.blank?
      assert !iou.bar.blank?
      assert iou.beverage.blank?
      assert !iou.total.blank?
      assert_equal "sent", iou.status
      assert_equal user, iou.recipient
      assert !iou.new_record?, iou.errors.full_messages.to_sentence
    end
  end

  should "not create iou without an email or phone" do
    #assert_no_difference 'Iou.count' do
      iou = Factory.build(:iou, :recipient_email => nil, :recipient_phone => nil)
      iou.save
      assert iou.errors[:recipient_email]
      assert !iou.sender.blank?
      assert !iou.status.blank?
      assert iou.recipient_email.blank?
      assert iou.recipient.blank?
      assert !iou.sender.blank?
      assert iou.beer.blank?
      assert iou.brand.blank?
      assert !iou.bar.blank?
      assert iou.beverage.blank?
      assert !iou.total.blank?
      assert_equal "sent", iou.status
      assert iou.new_record?, iou.errors.full_messages.to_sentence
    #end
  end

  should "not create iou with a malformatted email" do
    assert_no_difference 'Iou.count' do
      iou = Factory.build(:iou, :recipient_email => "notafuckingemail")
      iou.save

      assert iou.errors[:recipient_email]
      assert !iou.sender.blank?
      assert !iou.status.blank?
      assert !iou.recipient_email.blank?
      assert iou.recipient.blank?
      assert !iou.sender.blank?
      assert iou.beer.blank?
      assert iou.brand.blank?
      assert !iou.bar.blank?
      assert iou.beverage.blank?
      assert !iou.total.blank?
      assert_equal "sent", iou.status
      assert iou.new_record?, iou.errors.full_messages.to_sentence
    end
  end

  should "NOT create iou without a sender" do
    assert_no_difference 'Iou.count' do
      iou = Factory.build(:iou, :sender => nil)
      iou.save

      assert iou.errors[:sender_id]
      assert iou.sender.blank?
      assert !iou.status.blank?
      assert !iou.recipient_email.blank?
      assert iou.recipient.blank?
      assert iou.sender.blank?
      assert iou.beer.blank?
      assert iou.brand.blank?
      assert !iou.bar.blank?
      assert iou.beverage.blank?
      assert !iou.total.blank?
      assert_equal "sent", iou.status
      assert iou.new_record?, iou.errors.full_messages.to_sentence
    end
  end

  context "scopes" do
    should "not return records with same sender" do
      sender = Factory(:user)
      iou_1 = Factory(:iou, :sender => sender)
      Factory(:iou, :sender => sender)
      assert_equal [iou_1], Iou.with_unique_sender.all
    end
  end
end
