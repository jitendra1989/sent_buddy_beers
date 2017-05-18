class Admin::DashboardController < Admin::BaseController

  def index
    @vouchers_sold = Iou.paid.sum(:quantity)
    @vouchers_redeemed = Iou.redeemed.length + Voucher.redeemed.length
    @vouchers_open = Voucher.redeemable.length
    @vouchers_expired = Iou.expired.sum(:quantity)
    @vouchers_promotional = Iou.company_promotional.sum(:quantity)
  end

  def get_users
    date = DateTime.now.in_time_zone(session[:time_zone_name]).to_date
    case params[:day]
      when 'today'
        @users = User.find_user_with_created_at(DateTime.now.beginning_of_day, DateTime.now.end_of_day)
      when 'weekly'
        @users = User.find_user_with_created_at(date.beginning_of_week, date.end_of_week)
      when 'monthly'
        @users = User.find_user_with_created_at(date.beginning_of_month, date.end_of_month)
      when 'total_users'
        @users = User.get_users
      else
        @users = "Wrong parameter"
      end
    @users
  end
  def get_buddybucks
    date = DateTime.now.in_time_zone(session[:time_zone_name]).to_date
    case params[:day]
      when 'today'
        @buddybucks = CreditEvent.find_buy_buddybucks_with_created_at(DateTime.now.beginning_of_day, DateTime.now.end_of_day)
      when 'weekly'
        @buddybucks = CreditEvent.find_buy_buddybucks_with_created_at(date.beginning_of_week, date.end_of_week)
      when 'monthly'
        @buddybucks = CreditEvent.find_buy_buddybucks_with_created_at(date.beginning_of_month, date.end_of_month)
        #@buddybucks = CreditEvent.find_buy_buddybucks_with_created_at((DateTime.now - 3.years).beginning_of_year.to_date, (DateTime.now - 3.years).end_of_year.to_date)
      else
        @users = "Wrong parameter"
      end
    @users
  end
end
