class Facebook::VouchersController < Facebook::BaseController
  
  before_filter :require_fb_user
  before_filter :initialize_fb_graph
  
  def show
    @voucher = Voucher.find(params[:id])
    if @voucher.iou.recipient == current_user
      @iou = @voucher.iou
    else
      redirect_to facebook_root_url
    end
  end
  
end
