require 'test_helper'

class PayoutModelTest < ActiveSupport::TestCase

  should belong_to(:bar)
  should validate_presence_of(:bar_id)
  should validate_presence_of(:low_cents)
  should validate_presence_of(:currency)
  should validate_presence_of(:percent_payout)
  should validate_numericality_of(:low_cents)
  should validate_numericality_of(:high_cents)
  should validate_numericality_of(:percent_payout)

  context "a bar" do

    setup do
      @affiliate = Factory.create(:affiliate)
      @bar = Factory.create(:bar, :affiliate => @affiliate)
    end

    context "using the old payout model" do

      # Automatically created when bar is created
      setup do
        @price = Factory.create(:price, :bar => @bar, :cents => 250)
      end

      context "with vouchers purchased for it" do

        setup do
          @iou = Factory.create(:iou, :quantity => 2, :bar => @bar, :price => @price)
          @iou.paid!
        end

        should "have 2 vouchers" do
          assert @iou.vouchers.size == 2
        end

        context "one of which is redeemed" do

          setup do
            #@iou.vouchers.first.redeem! # this uses write_attribute and therefore doesn't really redeem the voucher. It must be passed within nested attributes.
            @redeemed_voucher = @iou.vouchers.first
            @redeemed_voucher.redemption_code = @redeemed_voucher.redemption_token
            @redeemed_voucher.save
          end

          should "have one redeemable voucher" do
            assert @iou.vouchers.redeemable.size == 1, @iou.vouchers.redeemable.inspect
          end

          context "and one of which is expired" do

            setup do
              @expired_voucher = @iou.vouchers.redeemable.first
              @iou.expire!
            end

            should "have line items" do
              assert @bar.line_items.present?
            end

            should "have 2 line items" do
              assert @bar.line_items.size == 2, @bar.line_items.inspect
            end

            should "have 1 line item with a redeemed status" do
              assert @bar.line_items.redeemed.size == 1
            end

            should "have the redeemed line item's voucher match the redeemed voucher" do
              assert @bar.line_items.redeemed.first.voucher == @redeemed_voucher
            end

            should "have 1 line item with a expired status" do
              assert @bar.line_items.expired.size == 1
            end

            should "have the expired line item's voucher match the expired voucher" do
              assert @bar.line_items.expired.first.voucher == @expired_voucher
            end

            should "have the redeemed line item with a payout percentage of 30%" do
              assert @bar.line_items.redeemed.first.payout_percent == "30"
            end

            should "have the expired line item with a payout percentage of 0%" do
              assert @bar.line_items.expired.first.payout_percent == "0"
            end

            should "have the redeemed line item's cents be 75" do
              assert @bar.line_items.redeemed.first.cents == 75
            end

            should "have the expired line item's cents be 0" do
              assert @bar.line_items.expired.first.cents == 0
            end

            context "and has a payment created for it's affiliate" do

              setup do
                @affiliate.create_payment!(1.month.ago.beginning_of_month, 1.day.from_now)
                @payment = @affiliate.payments.first
              end

              should "have a payment" do
                assert @affiliate.payments.size == 1
              end

              should "equal the total of the line items" do
                assert (@payment.line_items.order("id") - @bar.line_items.order("id")).blank?
              end

              should "have it's payment amount equal the payment amounts of the line items" do
                assert @payment.cents == @bar.line_items.sum(:cents)
              end

              should "have a payment of 75 cents" do
                assert @payment.cents == 75
              end
            end
          end
        end
      end
    end

    context "using the new payout model" do

      setup do
        @low_price = Factory.create(:price, :bar => @bar, :cents => 100)
        @mid_price = Factory.create(:price, :bar => @bar, :cents => 200)
        @high_price = Factory.create(:price, :bar => @bar, :cents => 500)
        @bar.payout_models.each(&:destroy)
        Factory.create(:payout_model, :bar => @bar, :low_cents => 0, :high_cents => 100, :percent_payout => 100)
        Factory.create(:payout_model, :bar => @bar, :low_cents => 101, :high_cents => 250, :percent_payout => 75)
        Factory.create(:payout_model, :bar => @bar, :low_cents => 251, :percent_payout => 50)
      end

      context "with 2 vouchers purchased for each category" do

        setup do
          @low_iou = Factory.create(:iou, :quantity => 2, :bar => @bar, :price => @low_price)
          @low_iou.paid!
          @mid_iou = Factory.create(:iou, :quantity => 2, :bar => @bar, :price => @mid_price)
          @mid_iou.paid!
          @high_iou = Factory.create(:iou, :quantity => 2, :bar => @bar, :price => @high_price)
          @high_iou.paid!
        end

        context "one of which is redeemed" do

          setup do
            @low_redeemed_voucher = @low_iou.vouchers.first
            @low_redeemed_voucher.redemption_code = @low_redeemed_voucher.redemption_token
            @low_redeemed_voucher.save
            @mid_redeemed_voucher = @mid_iou.vouchers.first
            @mid_redeemed_voucher.redemption_code = @mid_redeemed_voucher.redemption_token
            @mid_redeemed_voucher.save
            @high_redeemed_voucher = @high_iou.vouchers.first
            @high_redeemed_voucher.redemption_code = @high_redeemed_voucher.redemption_token
            @high_redeemed_voucher.save
          end

          should "have one redeemable voucher left" do
            assert @low_iou.vouchers.redeemable.size == 1
            assert @mid_iou.vouchers.redeemable.size == 1
            assert @high_iou.vouchers.redeemable.size == 1
          end

          context "and one of which is expired" do

            setup do
              @low_expired_voucher = @low_iou.vouchers.redeemable.first
              @low_iou.expire!
              @mid_expired_voucher = @mid_iou.vouchers.redeemable.first
              @mid_iou.expire!
              @high_expired_voucher = @high_iou.vouchers.redeemable.first
              @high_iou.expire!
            end

            should "have line items" do
              assert @bar.line_items.present?
            end

            should "have 6 line items" do
              assert @bar.line_items.size == 6
            end

            should "have 3 line items with a redeemed status" do
              assert @bar.line_items.redeemed.size == 3
            end

            should "have 3 line items with a expired status" do
              assert @bar.line_items.expired.size == 3
            end

            should "have the redeemed line items match the redeemed vouchers" do
              vouchers = @bar.line_items.redeemed.collect{ |li| li.voucher }
              assert vouchers.include?(@low_redeemed_voucher)
              assert vouchers.include?(@mid_redeemed_voucher)
              assert vouchers.include?(@high_redeemed_voucher)
            end

            should "have the expired line items match the expired vouchers" do
              vouchers = @bar.line_items.expired.collect{ |li| li.voucher }
              assert vouchers.include?(@low_expired_voucher)
              assert vouchers.include?(@mid_expired_voucher)
              assert vouchers.include?(@high_expired_voucher)
            end

            should "have the low redeemed line_item with a payout percentage of 100% and cents of 100" do
              @low_redeemed_line_item = @bar.line_items.find_by_voucher_id(@low_redeemed_voucher.id)
              assert @low_redeemed_line_item.payout_percent == "100", @low_redeemed_line_item.inspect
              assert @low_redeemed_line_item.cents == 100
            end

            should "have the low expired line_item with a payout percentage of 0% and cents of 0" do
              @low_expired_line_item = @bar.line_items.find_by_voucher_id(@low_expired_voucher.id)
              assert @low_expired_line_item.payout_percent == "0"
              assert @low_expired_line_item.cents == 0
            end

            should "have the mid redeemed line_item with a payout percentage of 75% and cents of 150" do
              @mid_redeemed_line_item = @bar.line_items.find_by_voucher_id(@mid_redeemed_voucher.id)
              assert @mid_redeemed_line_item.payout_percent == "75"
              assert @mid_redeemed_line_item.cents == 150
            end

            should "have the mid expired line_item with a payout percentage of 0% and cents of 0" do
              @mid_expired_line_item = @bar.line_items.find_by_voucher_id(@mid_expired_voucher.id)
              assert @mid_expired_line_item.payout_percent == "0"
              assert @mid_expired_line_item.cents == 0
            end

            should "have the high redeemed line_item with a payout percentage of 50% and cents of 250" do
              @high_redeemed_line_item = @bar.line_items.find_by_voucher_id(@high_redeemed_voucher.id)
              assert @high_redeemed_line_item.payout_percent == "50"
              assert @high_redeemed_line_item.cents == 250
            end

            should "have the high expired line_item with a payout percentage of 0% and cents of 0" do
              @high_expired_line_item = @bar.line_items.find_by_voucher_id(@high_expired_voucher.id)
              assert @high_expired_line_item.payout_percent == "0"
              assert @high_expired_line_item.cents == 0
            end

            context "and has a payment created for it" do

              setup do
                @affiliate.create_payment!(1.month.ago.beginning_of_month, 1.day.from_now)
                @payment = @affiliate.payments.first
              end

              should "have a payment" do
                assert @affiliate.payments.size == 1
              end

              should "equal the total of the line items" do
                assert (@payment.line_items.order("id") - @bar.line_items.order("id")).blank?
              end

              should "have it's payment amount equal the payment amounts of the line items" do
                assert @payment.cents == @bar.line_items.sum(:cents)
              end

              should "have a payment of 500 cents" do
                assert @payment.cents == 500
              end
            end
          end
        end
      end
    end
  end
end
