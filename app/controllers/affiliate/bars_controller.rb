class Affiliate::BarsController < Affiliate::BaseController
  before_filter :get_bar, :except => [:index]

  def index
  end

  def show
    # @outstanding_ious = @bar.ious.outstanding + @bar.ious.expired_since(1.week.ago.beginning_of_day)
    # @outstanding_vouchers = @bar.vouchers.redeemable + @bar.vouchers.expired_since(6.months.ago.beginning_of_day)
    # @past_ious = @bar.vouchers.redeemed
    @activity = Iou.unscoped.where(:promotional => false, :company_promotional => false, :paid => true, :expired => false, :bar_id => @bar.id).order("updated_at DESC").paginate(:page => params[:page], :per_page => 20)
  end

  def edit
  end

  def update
    voucher_count = @bar.vouchers.redeemable.size
    if @bar.update_attributes(params[:bar])
      if params[:bar].has_key?("vouchers_attributes")
        if voucher_count == @bar.vouchers(true).redeemable(true).size
          flash[:error] = t("affiliate.bars.update.none_redeemed")
        elsif voucher_count > @bar.vouchers(true).redeemable(true).size
          flash[:notice] = t("affiliate.bars.update.some_redeemed", :number => voucher_count - @bar.vouchers(true).redeemable(true).size)
        end
      else
        flash[:notice] = t("affiliate.bars.update.success")
      end
      redirect_to affiliate_bar_url(@bar)
    else
      flash[:error] = t("affiliate.bars.update.error")
      render :action => 'edit'
    end
  end

  def vouchers
    if params[:price]
      @lists = @bar.voucher_lists.valid.find_all_by_cents(params[:price])
    else
      @lists = @bar.voucher_lists.valid
    end
    respond_to do |format|
      format.html
      format.pdf { render :pdf => "#{t("affiliate.bars.voucher_list.pdf_file_name")}_#{@lists.first.cents}", :layout => "pdf.haml", :show_as_html => !params[:debug].blank?}
    end
  end

  def gallery
    @gallery = @bar.gallery
    @photo = @gallery.photos.new
  end

  protected

  def get_bar
    @bar = Bar.find(params[:id] || params[:bar_id])
  end
end
