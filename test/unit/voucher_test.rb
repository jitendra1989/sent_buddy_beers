require 'test_helper'

class VoucherTest < ActiveSupport::TestCase
  fixtures :ious

  subject { Factory(:voucher) }

  should belong_to(:iou)
  should belong_to(:bar)
  should belong_to(:voucher_list)
  should have_many(:line_items)
  should validate_uniqueness_of(:token)

  context "An unsaved voucher" do
    setup { @voucher = Factory.build(:voucher) }

    # discountable concern tests
    should "have a total as a money object" do
      assert @voucher.total.present?
      assert @voucher.total.is_a?(Money)
    end

    should "return false for :discounted?" do
      assert_false @voucher.discounted?
    end

    context "with a discounted amount" do
      setup do
        @voucher.cents = 200
        @voucher.discounted = true
        @voucher.discounted_cents = 100
      end

      should "return the discounted cents as total" do
        assert_equal 100, @voucher.total.cents
      end
    end

    context "without a amount" do
      setup { @voucher.cents = nil }
      should "not save" do
        assert_no_difference "Voucher.count" do
          @voucher.save
          assert @voucher.new_record?
          assert @voucher.errors[:cents]
        end
      end
    end

    context "with a amount of zero" do
      setup { @voucher.cents = 0 }
      should "not save" do
        assert_no_difference "Voucher.count" do
          @voucher.save
          assert @voucher.new_record?
          assert @voucher.errors[:cents]
        end
      end
    end

    context "with a discounted amount of zero and discounted set to true" do
      setup do
        @voucher.discounted_cents = 0
        @voucher.discounted = true
      end
      should "not save" do
        assert_no_difference "Voucher.count" do
          @voucher.save
          assert @voucher.new_record?
          assert @voucher.errors[:discounted_cents]
        end
      end
    end

    context "with a discounted amount more than it's regular amount" do
      setup do
        @voucher.discounted_cents = 1000
        @voucher.discounted = true
      end
      should "not save" do
        assert_no_difference "Voucher.count" do
          @voucher.save
          assert @voucher.new_record?
          assert @voucher.errors[:discounted_cents]
        end
      end
    end

    context "sending amount, not cents" do
      setup do
        @voucher.cents = nil
        @voucher.amount = "2.00"
      end
      should "save and have amount" do
        assert_difference "Voucher.count" do
          @voucher.save
          assert !@voucher.new_record?
          assert @voucher.errors.blank?
          assert_equal @voucher.cents, 200
        end
      end
    end
  end

  context "A new voucher" do
    setup { @voucher = Factory(:voucher) }

    should "have a amount that is a money object" do
      assert_not_nil @voucher.amount
      assert @voucher.amount.is_a?(Money)
      assert_equal @voucher.amount.cents, @voucher.cents
    end

    should "have token and redemption_token created automatically" do
      assert_not_nil @voucher.token
      assert_not_nil @voucher.redemption_token
    end

    should "have a code that contains the token broken up in a format like 'A-BCD' and is a string" do
      assert_not_nil @voucher.code
      assert @voucher.code.include?(@voucher.token.first(1))
      assert @voucher.code.include?(@voucher.token.last(3))
      assert @voucher.code.include?("-")
      assert @voucher.code.is_a?(String)
    end

    should "have a coupon code that contains the token broken up in a format like 'A-BCD', the redemption token and is a string" do
      assert_not_nil @voucher.coupon
      assert @voucher.code.include?(@voucher.token.first(1))
      assert @voucher.code.include?(@voucher.token.last(3))
      assert @voucher.code.include?("-")
      assert @voucher.coupon.include?(@voucher.redemption_token)
      assert @voucher.coupon.is_a?(String)
    end

    should "return the code when passed to_s" do
      assert_equal @voucher.code, @voucher.to_s
    end

    context "can be claimed by passing an iou" do
      setup do
        @voucher_count = @voucher.bar.vouchers.length
        @voucher.claim!(@voucher.iou)
      end

      should "not change the number of vouchers in a bar" do
        assert_equal @voucher_count, @voucher.bar.vouchers.length
      end

      should "have an iou" do
        assert_not_nil @voucher.iou
      end

      should "now be redeemable" do
        assert @voucher.redeemable?
      end

      should "return it's ious created at date when passed date" do
        assert_equal @voucher.date, @voucher.iou.created_at.to_date
      end

      should "have the same prices and discounts as the iou" do
        assert_equal @voucher.iou.cents, @voucher.cents
        assert_equal @voucher.iou.discounted_cents, @voucher.discounted_cents
        assert_equal @voucher.iou.discounted, @voucher.discounted
      end
    end

    context "can be claimed by passing an iou with discounted price" do
      setup do
        @iou = @voucher.iou
        @iou.discounted = true
        @iou.discounted_cents = @iou.cents - 10
        @voucher.claim!(@iou)
      end

      should "assign discounted price" do
        assert @voucher.discounted
        assert_equal @iou.discounted_cents / @iou.quantity,  @voucher.discounted_cents
      end
    end

    should "raise an exception if #claim! fails" do
      @voucher.stubs(:valid?).returns(false)

      assert_raise ActiveRecord::RecordInvalid do
        @voucher.claim!(@voucher.iou)
      end
    end

    context "that can be redeemed" do
      setup do
        @line_items_count = LineItem.count
        @voucher.claim!(ious(:pending_payment_voucher))
        @voucher.redemption_code = @voucher.redemption_token
        @voucher.save
      end

      should "be redeemed" do
        assert @voucher.redeemed
      end

      should "have a date when it was redeemed" do
        assert @voucher.redeemed_at.present?
      end

      should "create a line_item" do
        assert_equal 1, LineItem.count - @line_items_count
      end
    end
  end
end
