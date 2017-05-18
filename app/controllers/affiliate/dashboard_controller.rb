class Affiliate::DashboardController < Affiliate::BaseController
  def index
    redirect_to affiliate_bar_url(@bars.first) if @bars.length == 1
    @outstanding_ious = @bars.collect{ |b| b.ious.outstanding }.flatten
  end
end
