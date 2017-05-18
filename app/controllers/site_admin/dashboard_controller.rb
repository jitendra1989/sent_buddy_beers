class SiteAdmin::DashboardController < SiteAdmin::BaseController
  def index
    @vouchers_sold = Iou.for_site_admin(current_user).paid.sum(:quantity)
    @vouchers_redeemed = Iou.for_site_admin(current_user).redeemed.length + Voucher.for_site_admin(current_user).redeemed.length
    @vouchers_open = Voucher.for_site_admin(current_user).redeemable.length
    @vouchers_expired = Iou.for_site_admin(current_user).expired.sum(:quantity)
    @vouchers_promotional = Iou.for_site_admin(current_user).company_promotional.sum(:quantity)
  end
end
