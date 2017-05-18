class Admin::BarsController < Admin::BaseController
  respond_to :html

  def index
    @bars = params[:inactive] ? Bar.inactive.alphabetically_by_country_and_city : params[:pending] ? Bar.pending.alphabetically_by_country_and_city : Bar.active.alphabetically_by_country_and_city
  end

  def show
    @vouchers = bar.vouchers.redeemable
    respond_with :admin, bar
  end

  def new
    @bar = Bar.new
    respond_with :admin, @bar
  end

  def create
    @bar = Bar.new(params[:bar].merge(:pending => false))
    if @bar.city_id.blank? and params[:new_city_name].present? and !params[:bar][:country_id].blank?
      @bar.city = City.create(:name => params[:new_city_name], :country_id => params[:bar][:country_id])
    end
    flash[:notice] = "Venue created!" if @bar.save
    respond_with :admin, @bar
  end

  def edit
    respond_with :admin, bar
  end

  def update
    voucher_count = bar.vouchers.redeemable.size
    if bar.update_attributes(params[:bar])
      if params[:bar].has_key?("vouchers_attributes")
        if voucher_count == bar.vouchers(true).redeemable(true).size
          flash[:error] = t("affiliate.bars.update.none_redeemed")
        elsif voucher_count > bar.vouchers(true).redeemable(true).size
          flash[:notice] = t("affiliate.bars.update.some_redeemed", :number => voucher_count - bar.vouchers(true).redeemable(true).size)
        end
      else
        flash[:notice] = t("affiliate.bars.update.success")
      end
      respond_with :admin, bar
    else
      flash[:error] = t("affiliate.bars.update.error")
      render :action => 'edit'
    end
  end

  def destroy
    flash[:notice] = "Venue removed!" if bar.destroy
    respond_with :admin, bar
  end

  def vouchers
    @voucher_lists = bar.voucher_lists.valid
    @voucher_lists = @voucher_lists.where(:cents => params[:price]) if params[:price]

    respond_to do |format|
      format.html
      format.pdf { render :pdf => "#{t("affiliate.bars.voucher_list.pdf_file_name")}_#{@voucher_lists.first.cents}", :layout => "pdf.haml", :show_as_html => params[:debug]}
    end
  end

  def gallery
    @gallery = bar.gallery
  end

  def get_venues
    date = DateTime.now.in_time_zone(session[:time_zone_name]).to_date
    case params[:day]
      when 'today'
        @venues = Bar.find_venue_with_created_at(DateTime.now.beginning_of_day, DateTime.now.end_of_day)
      when 'weekly'
        @venues = Bar.find_venue_with_created_at(date.beginning_of_week, date.end_of_week)
      when 'monthly'
        @venues = Bar.find_venue_with_created_at(date.beginning_of_month, date.end_of_month)
      when 'total_venues'
        @venues = Bar.get_venues
      else
        @venues = "Wrong parameter"
      end
    @venues
  end

  protected

  def bar
    @bar ||= Bar.find(params[:id] || params[:bar_id])
  rescue ActiveRecord::RecordNotFound
    other_locale = I18n.locale == :de ? :en : :de
    bar = I18n.with_locale(other_locale) do
      Bar.find(params[:id] || params[:bar_id])
    end
    redirect_to bar, :locale => other_locale, :status => :moved_permanently
  end
end
