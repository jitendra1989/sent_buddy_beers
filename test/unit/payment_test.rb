require 'test_helper'

class PaymentTest < ActiveSupport::TestCase

  should have_many(:line_items)
  should belong_to(:affiliate)

  should validate_presence_of(:affiliate_id)
  should validate_presence_of(:beginning_at)
  should validate_presence_of(:ending_at)

  context "a payment" do
    setup do
      @payment = Factory(:payment)
    end

    should "have an amount as a money object" do
      assert @payment.amount.present?
      assert @payment.amount.is_a?(Money)
    end

    context "with no line_items" do
      should "have a total calculated at zero" do
        assert @payment.amount.to_s == "0,00"
      end
    end

    context "with line items" do
      setup do
        @iou = Factory.create(:iou, :quantity => 2, :price => Factory(:price, :cents => 499))
        @iou.paid!
        @iou.vouchers.each do |voucher|
          voucher.redeem!
          voucher.save
        end
        @iou.bar.affiliate.create_payment!(2.years.ago, DateTime.tomorrow.end_of_day)
        @payment = @iou.bar.affiliate.payments.last
      end

      should "have a total calculated at the price of all redeemed vouchers (2 x 4.99) less the bar's percent cut (70)" do
        assert_equal 2.98, @payment.amount.to_f, @payment.amount
      end

      context "that's paid" do
        setup do
          @email_count = ActionMailer::Base.deliveries.length
          @payment.paid!
        end

        should "be marked as paid" do
          assert @payment.paid
        end

        should "have a date for when it's paid" do
          assert @payment.paid_at.present?
        end

        should "send an email" do
          assert_equal 1, ActionMailer::Base.deliveries.length - @email_count
        end
      end
    end
  end
end
