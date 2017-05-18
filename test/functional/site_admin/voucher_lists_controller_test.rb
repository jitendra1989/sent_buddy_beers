require 'test_helper'

class SiteAdmin::VoucherListsControllerTest < ActionController::TestCase
  fixtures :all
  
  context "on get to show with a closed voucher list" do
    setup do
      sign_in Factory(:site_admin)
      bars(:active_bar).save
      @prev_list = Factory(:voucher_list, :bar_id => bars(:active_bar).id, :cents => bars(:active_bar).prices.first.cents, :currency => bars(:active_bar).prices.first.currency)
      @prev_list.vouchers.each { |v| v.claim!(Iou.paid.first) }
      @list = VoucherList.where(:closed => false, :cents => @prev_list.cents, :bar_id => @prev_list.bar_id).first
      get :show, :bar_id => bars(:active_bar).id, :id => @prev_list.id
    end
    
    should respond_with(:success)
    should render_template(:show)
    should_not set_the_flash
    
    should assign_to(:bar)
    should assign_to(:list)
    should assign_to(:previous_list)
    
    should "match list" do
      assert_equal assigns(:list), @prev_list
    end
    
    should "match prev list" do
      assert_equal assigns(:previous_list), @list
    end
  end

end
