class SiteAdmin::BarsController < SiteAdmin::BaseController
  respond_to :html

  def index
    @bars = Bar.for_site_admin(current_user)
    @bars = params[:inactive] ? @bars.inactive.alphabetically_by_country_and_city : params[:pending] ? @bars.pending.alphabetically_by_country_and_city : @bars.active.alphabetically_by_country_and_city
  end

  def show
    @vouchers = bar.vouchers.redeemable
    respond_with :site_admin, bar
  end

  def new
    @bar = Bar.new
    respond_with :site_admin, @bar
  end

  def create
    @bar = Bar.new(params[:bar].merge(:pending => false))
    if @bar.city_id.blank? and params[:new_city_name].present? and !params[:bar][:country_id].blank?
      @bar.city = City.create(:name => params[:new_city_name], :country_id => params[:bar][:country_id])
    end
    flash[:notice] = "Venue created!" if @bar.save
    respond_with :site_admin, @bar
  end

  def edit
    respond_with :site_admin, bar
  end

  def update
    flash[:notice] = "Venue updated!" if bar.update_attributes(params[:bar])
    respond_with :site_admin, bar
  end

  def destroy
    flash[:notice] = "Venue removed!" if bar.destroy
    respond_with :site_admin, bar
  end

  def vouchers
    @voucher_lists = bar.voucher_lists.valid
    @voucher_lists = @voucher_lists.where(:cents => params[:price]) if params[:price]

    respond_to do |format|
      format.html
      format.pdf { render :pdf => "#{t("affiliate.bars.voucher_list.pdf_file_name")}_#{@voucher_lists.first.cents}", :layout => "pdf.haml", :show_as_html => !params[:debug].blank?}
    end
  end

  protected

  def bar
    @bar ||= Bar.for_site_admin(current_user).find(params[:id] || params[:bar_id])
  end
end
