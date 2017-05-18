class Admin::MetricsController < Admin::BaseController

  def index
    # @metrics = Metric.all
    # logger.debug("!!!! #{Date.civil(params['metric']['start_date(1i)'].to_i,params['metric']['start_date(2i)'].to_i,params['metric']['start_date(3i)'].to_i)}")
    if params['metric']
      if params['metric']['start_date(1i)'] and params['metric']['start_date(2i)'] and params['metric']['start_date(3i)'] and params['metric']['end_date(1i)'] and params['metric']['end_date(2i)'] and params['metric']['end_date(3i)'].to_i
        if params[:metric][:type]
        
          @start_date = Date.civil(params['metric']['start_date(1i)'].to_i,params['metric']['start_date(2i)'].to_i,params['metric']['start_date(3i)'].to_i).beginning_of_day
          @end_date = Date.civil(params['metric']['end_date(1i)'].to_i,params['metric']['end_date(2i)'].to_i,params['metric']['end_date(3i)'].to_i).end_of_day
        
          case params[:metric][:type]
          when "Vouchers Sold"
            @sum = Iou.recent.where(:paid_at => @start_date..@end_date).sum(:quantity)
            @total = Iou.recent.sum(:quantity)
          when "User Signups"
            @sum = User.active.where(:confirmed_at => @start_date..@end_date).count
            @total = User.active.count
          when "Vouchers Bought by New Users"
            @sum = Iou.recent.where(:paid_at => @start_date..@end_date).includes(:sender).where(:users => {:confirmed_at => @start_date..@end_date}).sum(:quantity)
          when "Recurring User Purchases"
            ious = Iou.with_unique_sender.recent.where(:paid_at => @start_date..@end_date)
            @sum = ious.collect{ |i| i.sender.id if i.sender.sent_ious.where(["paid_at <= ?", @start_date]).count > 0 }.compact.count
            @total = User.active.collect{ |u| u.sent_ious.count > 1 ? 1 : 0}.inject(:+)
          when "Total Users"
            @sum = User.active.where("confirmed_at <= ?", @end_date).count
          when "Vouchers Redeemed"
            @sum = Voucher.where(:redeemed_at => @start_date..@end_date).count  
            @total = Voucher.where('redeemed_at is not null').count
          when "Total value of vouchers sold"
            @sum = Iou.recent.where(:paid_at => @start_date..@end_date).where(:currency => "EUR").sum(:cents) + Money.new(Iou.recent.where(:paid_at => @start_date..@end_date).where(:currency => "USD").sum(:cents)).exchange_to("EUR").cents + Money.new(Iou.recent.where(:paid_at => @start_date..@end_date).where(:currency => "CHF").sum(:cents)).exchange_to("EUR").cents
            @sum = Money.new(@sum, "EUR")
            @total = Iou.where(:currency => "EUR").sum(:cents) + Money.new(Iou.recent.where(:currency => "USD").sum(:cents)).exchange_to("EUR").cents + Money.new(Iou.recent.where(:currency => "CHF").sum(:cents)).exchange_to("EUR").cents
            @total = Money.new(@total, "EUR")
          end
        
        else
          flash.now[:error] = "You need to choose a metric"
        end
      end
    end
  end
 
end