require 'test_helper'

class PriceTest < ActiveSupport::TestCase
  fixtures :all

  should belong_to(:beer)
  should belong_to(:bar)
  should belong_to(:drink_type)
  should belong_to(:beverage)
  should have_many(:ious)

  should validate_presence_of(:cents)
  should validate_presence_of(:name)
  should validate_numericality_of(:cents)
  should validate_numericality_of(:discounted_cents)
  should_not allow_value(0).for(:cents)
  
  should have_attached_file(:photo)

  context "A price" do
    setup do
      Factory(:beverage)
      @price = Factory.build(:price, :cents => 200)
    end

    # discountable concern tests
    should "have a total as a money object" do
      assert @price.total.present?
      assert @price.total.is_a?(Money)
    end

    should "return false for :discounted?" do
      assert !@price.discounted?
      assert_equal @price.discounted?, @price.discounted
    end

    context "with no bar" do
      setup { @price.bar = nil }
      
      should "not be valid" do
        assert !@price.valid?
      end
    end
    
    context "with no beverage" do
      setup do
        @price.beverage = nil 
        @price.save
      end
      
      should "automatically have one assigned when saved" do
        assert_not_nil @price.beverage
      end
    end

    context "with a discounted amount" do
      setup do
        @price.cents = 200
        @price.discounted = true
        @price.discounted_cents = 100
      end

      should "return the discounted cents as total" do
        assert_equal 100, @price.total.cents
      end
    end

    context "with a discounted amount of zero and discounted set to true" do
      setup do
        @price.discounted_cents = 0
        @price.discounted = true
      end

      should "not save" do
        assert_no_difference "Price.count" do
          @price.save
          assert @price.new_record?
          assert @price.errors[:discounted_cents]
        end
      end
    end

    context "with a discounted amount more than it's regular amount" do
      setup do
        @price.discounted_cents = 400
        @price.discounted = true
      end

      should "not save" do
        assert_no_difference "Price.count" do
          @price.save
          assert @price.new_record?
          assert @price.errors[:discounted_cents]
        end
      end
    end

    context "sending amount, not cents" do
      setup do
        @price.cents = nil
        @price.amount = "2.00"
      end

      should "save and have amount" do
        assert_difference "Price.count" do
          @price.save
          assert !@price.new_record?
          assert @price.errors.blank?
          assert_equal @price.cents, 200
        end
      end
    end

    should "save with all acceptible fields" do
      assert_difference "Price.count" do
        @price.save
        assert !@price.new_record?
        assert @price.errors.blank?
      end
    end
  end

  context "a bar with two prices that has sold some vouchers" do
    setup do 
      @price = Factory(:price)
      @bar = @price.bar
      @cents = @price.cents
      Factory(:price, :bar => @bar, :cents => 30000) #second price
      @iou = Factory(:iou, :bar => @bar, :price => @price)
      @iou.paid!
      @tiers_count = @bar.tiers.length
      @lists_count = @bar.voucher_lists.length
    end
    
    should "have paid ious" do
      assert @bar.ious.paid.present?
    end
    
    should "have an iou with vouchers" do
      assert @iou.vouchers.present?
    end
    
    should "have one price tier" do
      assert_equal 1, @bar.tiers.length
    end
    
    context "and changes the price of an existing drink to create a new price tier" do
      setup do 
        @price.update_attribute(:cents, @cents + 100)
      end

      should "increase the number of price tiers for the bar" do
        assert_equal 1, @bar.reload.tiers.length - @tiers_count, @bar.reload.tiers
      end

      should "increase the number of voucher lists for the bar" do
        assert_equal 1, @bar.voucher_lists(true).length - @lists_count, @bar.voucher_lists(true).inspect
      end

      should "keep the old vouchers that were for the original price in the original voucher list" do
        assert_equal 0, @bar.voucher_lists(true).find_by_cents(@cents + 100).vouchers.taken.length, @price.cents
        assert_equal 1, @bar.voucher_lists(true).find_by_cents(@cents).vouchers.taken.length, @price.cents
      end
    end

    context "that deletes a drink from their list resulting in no more drinks at that price" do
      setup { @bar.prices.each(&:destroy) }

      should "no longer allow drinks to be purchased on the old price list" do
        assert_equal 0, @bar.vouchers.available.where(:cents => @cents).where(:currency => "EUR").count
      end

      should "but keep the ones that were purchased there until they expire" do
        assert !@bar.voucher_lists.find_by_cents(@cents).vouchers.blank?
      end
    end

    context "that changes the price of a drink so that it fits under an existing price tier" do
      setup do
        @new_price = Factory(:price, :bar => @bar, :cents => 35000)
        @iou = Factory(:iou, :bar => @bar, :price => @new_price)
        @iou.paid!
        @new_price.update_attribute(:cents, @cents)
      end

      should "ensure all new vouchers would be purchased from the existing list" do
        assert_difference "@bar.voucher_lists.find_by_cents(@cents).vouchers.taken.length" do
          @iou = Factory(:iou, :bar => @bar, :price => Factory(:price, :cents => @cents))
          @iou.paid!
        end
      end

      should "and all old vouchers would be legacy." do
        assert !@bar.voucher_lists.find_by_cents(35000).vouchers.blank?
        assert @bar.voucher_lists.find_by_cents(35000).vouchers(true).available.blank?, @new_price.cents.to_s
      end
    end
  end

  context "a bar with an active voucher list for a specific price" do
    setup do 
      @price = Factory(:price)
      @bar = @price.bar
    end
    
    should "have a voucher list" do
      assert_equal 1, @bar.voucher_lists.length
    end
    
    context "and an archived voucher list" do
      setup do
        @vl = Factory(:voucher_list, :bar => @price.bar, :cents => @price.cents, :currency => @price.currency, :archived => true, :closed => true)
        @lists_count = @bar.voucher_lists.reload.length
      end
    
      should "be saved" do
        assert @vl.persisted?, @vl.errors.full_messages.join(", ")
      end
    
      should "have two voucher lists" do
        assert_equal 2, @lists_count, @bar.voucher_lists.inspect
      end
    
      context "that adds a new price with the same cents" do
      
        setup { Factory(:price, :cents => @price.cents, :bar => @bar, :discounted_cents => 180, :discounted => true) }
      
        should "not create a new voucher list" do
          assert_equal @lists_count, @bar.reload.voucher_lists.length
        end
      end
    end
  end

end
