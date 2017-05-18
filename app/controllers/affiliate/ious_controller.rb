class Affiliate::IousController < Affiliate::BaseController

  before_filter :get_bar

  def index
    respond_to do |format|
      format.html do
        case params[:filter]
        when "past"
          @vouchers = @bar.vouchers.redeemed.order("vouchers.token asc").paginate(:page => params[:page], :per_page => 50)
        else  
          # Not sure what to do here at the moment as we don't want to show the bar their unredeemed vouchers
          @vouchers = @bar.vouchers.redeemable.order("vouchers.token asc").paginate(:page => params[:page], :per_page => 50)
        end
      end
      format.pdf do 
        @vouchers = [@bar.vouchers.where("ious.expired = ? AND redeemed = ?", false, false).includes(:iou) + @bar.vouchers.available].flatten.uniq
        render :pdf => "#{t("affiliate.bars.voucher_list.pdf_file_name")}_#{Date.today.to_s.parameterize}", :layout => "pdf.haml", :show_as_html => !params[:debug].blank?
      end
    end
  end

  def new
    @iou = Iou.new
  end

  def create
    @iou = Iou.new(params[:iou])
    @iou.sender = @current_user
    @iou.status = "valid"
    # TODO: figure out what site should be assigned here
    @iou.site   = Site.default
    @iou.promotional = true
    @iou.bar = @bar
    @iou.transaction do
      begin
        @iou.save
        @iou.paid!
        flash[:notice] = t("admin.ious.create.success")
        redirect_to affiliate_bar_url(@bar)
      rescue
        flash[:error] = t("admin.ious.create.error")
        render :action => :new
      end
    end
  end

  protected
    def get_bar
      @bar = Bar.find(params[:bar_id])
    end

end