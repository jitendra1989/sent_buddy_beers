require 'test_helper'

class AffiliateTest < ActiveSupport::TestCase
  setup { @affiliate = Factory(:affiliate) }

  should have_many(:bars)
  should have_many(:payments)

  should "return true when passed payment_prefs_empty" do
    assert @affiliate.payment_prefs_empty?
  end

  context "with a paypal address" do
    setup { @affiliate.update_attribute(:paypal_email, "email@paypal.com") }

    should "return false when passed payment_prefs_empty" do
      assert !@affiliate.payment_prefs_empty?
    end
  end

  context "with a (german) bank account" do
    setup do
      @affiliate.bank_account_name = "Travis Todd"
      @affiliate.bank_account_number = "10010001000100"
      @affiliate.bank_account_bank_code = "10050000"
      @affiliate.save!
    end

    should "return false when passed payment_prefs_empty" do
      assert !@affiliate.payment_prefs_empty?
    end
  end

  context "with a (european) bank account" do
    setup do
      @affiliate.bank_account_name = "Travis Todd"
      @affiliate.bank_account_number = "10010001000100"
      @affiliate.bank_account_iban = "10050000"
      @affiliate.bank_account_bic_swift = "10050000"
      @affiliate.save!
    end

    should "return false when passed payment_prefs_empty" do
      assert !@affiliate.payment_prefs_empty?
    end
  end

  context "with a partially filled out bank account" do
    setup do
      @affiliate.bank_account_name = "Travis Todd"
      @affiliate.bank_account_number = "10010001000100"
      @affiliate.save!
    end

    should "return true when passed payment_prefs_empty" do
      assert @affiliate.payment_prefs_empty?
    end
  end

  context "with many bars" do
    setup do
      2.times { Factory(:bar, :affiliate => @affiliate) }
    end

    should "have many bars" do
      assert @affiliate.bars.length > 1
    end

    context "with redeemed vouchers" do
      setup do
        @affiliate.bars.reload.each do |bar|
          price = Factory(:price, :bar => bar)
          2.times do
            Factory(:iou, :bar => bar, :price => price)
          end
          bar.ious.each do |i|
            i.paid!
            i.vouchers.reload.each do |v|
              v.redeem!
              v.save
            end
          end
        end
      end

      should "have redeemed vouchers" do
        @affiliate.bars.each do |bar|
          assert bar.vouchers.redeemed.present?, "bars = #{@affiliate.bars.inspect} bar = #{bar.inspect} ious = #{bar.ious.first.vouchers.inspect} redeemed = #{bar.vouchers.redeemed.inspect}"
        end
      end

      context "with a payment created for them" do
        setup { @affiliate.create_payment!(1.month.ago, Date.tomorrow.end_of_day) }

        should "have a payment" do
          assert @affiliate.payments.reload.present?
        end

        should "have an outstanding balance" do
          assert @affiliate.outstanding_balance.cents > 0
        end
      end
    end
  end

  context "scopes" do
    should "return affiliates with associated bars to given site ids" do
      site = Factory(:site)
      affiliate = Factory(:affiliate)
      bar = Factory(:bar, :affiliate => affiliate)
      bar.sites << site
      assert_equal [affiliate], Affiliate.for_site_ids(site.id).all
    end

    should "return affiliates with associated bars to given site_admin" do
      site = Factory(:site)
      affiliate = Factory(:affiliate)
      bar = Factory(:bar, :affiliate => affiliate)
      bar.sites << site
      site_admin = Factory(:site_admin)
      site_admin.sites << site
      assert_equal [affiliate], Affiliate.for_site_admin(site_admin).all
    end
  end
end
