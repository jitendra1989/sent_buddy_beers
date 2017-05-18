require 'test_helper'

class VoucherListTest < ActiveSupport::TestCase
  setup do
    @price = Factory(:price)
    @voucher_list = @price.bar.voucher_lists.first
  end

  should belong_to(:bar)
  should have_many(:vouchers)
  
  should "have an amount as a money object" do
    assert @voucher_list.amount.present?
    assert @voucher_list.amount.is_a?(Money)
  end
  
  should "not have an expiry date" do
    assert @voucher_list.expires_at.nil?
  end
  
  should "not be downloaded" do
    assert !@voucher_list.downloaded?
  end
  
  context "can be marked as downloaded" do
    setup { @voucher_list.downloaded! }
    
    should "be downloaded" do
      assert @voucher_list.downloaded?
    end
  end

  context "with all it's vouchers taken" do
    
    setup do
      @bar = @voucher_list.bar
      @iou = Factory(:iou, :bar => @bar, :price => @price)
      @voucher_list_count = @bar.voucher_lists.size
      @email_count = ActionMailer::Base.deliveries.length
    end
    
    context "and notifications set to true" do
      setup do
        @bar.update_attribute(:new_voucher_list_notification, true)
        @voucher_list.reload.vouchers.available.each { |v| v.claim!(@iou) }
      end
      
      should "increase the number of emails sent (CC'd to the bar owner, bro if it exists and buddybeers team)" do
        assert_equal 1, ActionMailer::Base.deliveries.length - @email_count
      end
    end
    
    context "and notifications set to false" do
      setup do
        @voucher_list.reload.vouchers.available.each { |v| v.claim!(@iou) }
      end
      
      should "be one voucher list" do
        assert_equal 1, @voucher_list_count
      end

      should "increase the amount of bar's voucher voucher_lists" do
        assert_equal 1, @bar.voucher_lists.size - @voucher_list_count, @bar.voucher_lists.collect { |v| v.vouchers.all?(&:taken?) }
      end

      should "have a closed voucher list" do
        assert @voucher_list.reload.closed
      end
    
      should "have an expiry date" do
        assert @voucher_list.reload.expires_at.present?
      end
    
      should "have a new voucher voucher_list that belongs to the bar" do
        assert_equal @bar, VoucherList.unscoped.order("created_at DESC").first.bar
      end
    
      should "have 50 vouchers on the new list" do
        assert_equal 50, VoucherList.unscoped.order("created_at DESC").first.vouchers.length
      end
    
      should "not increase the number of emails sent (CC'd to the bar owner, bro if it exists and buddybeers team)" do
        assert_equal 0, ActionMailer::Base.deliveries.length - @email_count
      end
    
      should "make sure the new voucher list is not archived or closed" do
        assert !VoucherList.find(:all, :order => 'created_at').last.closed?
        assert !VoucherList.find(:all, :order => 'created_at').last.archived?
      end
    end
  end
  
  context "with all it's vouchers taken and no affiliate" do
    setup do
      @bar = @voucher_list.bar      
      @bar.affiliate = nil
      @bar.new_voucher_list_notification = true
      @bar.save
      @iou = Factory(:iou, :bar => @bar, :price => @price)
      @email_count = ActionMailer::Base.deliveries.length
      @voucher_list.vouchers.available.each { |v| v.claim!(@iou) }
    end
    
    should "increase the number of emails sent (CC'd to the bar owner, bro if it exists and buddybeers team)" do
      assert_equal 1, ActionMailer::Base.deliveries.length - @email_count
    end 
  end
end
