class BarsController < ApplicationController
  before_filter :get_bar, :only => [:show, :confirm, :edit, :update, :submit, :upload_logo]
  before_filter :add_city_if_missing, :only => [:create, :update]
  before_filter :redirect_if_active_or_not_pending, :only => [:edit, :update, :submit]
  layout "new_application"

  def index
    @all_bars = current_site.bars.active
    @bars = @all_bars.alphabetically_by_country_and_city.paginate(:page => params[:page], :per_page => 20)
    if params[:origin]
      @all_bars = current_site.bars.active.geocoded.within(params[:origin][:distance] || 20, :origin => params[:origin][:location]).order('distance asc')
      if @all_bars.empty?
        flash.now[:error] = params[:origin].key?(:distance) ? t("bars.search.no_results", :location => params[:origin][:location], :distance => params[:origin][:distance]) : t("bars.search.no_results_20", :location => params[:origin][:location], :distance => 100)
      else
        @bars = @all_bars.paginate(:page => params[:page], :per_page => 20)
      end
    end
    respond_to do |format|
      format.html do
        if request.xhr?
          #sleep(10) # make request a little bit slower to see loader :-)
          render :partial => 'bars/bars'
        end
      end
      format.xml { render :xml => @bars.to_xml }
      format.json { render :json => @bars.to_json }
    end
  rescue Geokit::Geocoders::GeocodeError
    @flash_not_html_safe = true
    flash.now[:error] = t("bars.search.address_not_found", :location => params[:origin][:location])
    @bars = current_site.bars.active.alphabetically_by_country_and_city.paginate(:page => params[:page], :per_page => 20)
  end

  def show
    @feed = @bar.ious.public.recent.first(15)
    @geocoords = Geokit::Geocoders::MultiGeocoder.geocode(@bar.full_address) if @bar.geocoded?
    # Don't index the page if there is no translation for the bar's description
    @noindex = true unless @bar.translations.detect{ |t| t.locale.to_sym == I18n.locale }
    Gabba::Gabba.new("UA-750037-13", "#{current_site.subdomain ? current_site.subdomain : "www"}.buddybeers.com").event("Merchants", "View", @bar.name) if Rails.env.production?
  end

  def new
    @bar = current_site.bars.build
    3.times { @bar.prices.build(:amount => 0.00) } unless @bar.prices.present?
  end

  def create
    @bar = Bar.new(params[:bar])
    @bar.active = false
    @bar.pending = true
    unless @bar.sites.include?(current_site)
      @bar.sites << current_site
    end
    if @bar.save
      redirect_to confirm_bar_path(@bar)
    else
      flash[:error] = t("bars.create.error")
      3.times { @bar.prices.build(:amount => 0.00) } unless @bar.prices.present?
      render :new
    end
  end

  def edit
  end

  def update
    if @bar.update_attributes(params[:bar])
      redirect_to confirm_bar_url(@bar), :notice => t("affiliate.bars.update.success")
    else
      flash[:error] = t("affiliate.bars.update.error")
      render :edit
    end
  end

  # Upload Logo
  def upload_logo
    @bar.update_attributes(:logo => params[:bar][:logo]) if !params[:bar].blank? && !params[:bar][:logo].blank?
    redirect_to bar_url(@bar)
  end

  def confirm
    if @bar.active
      flash[:error] = t("global.access_denied")
      redirect_to root_url
    end
    @menu = @bar.prices
    @geocoords = Geokit::Geocoders::MultiGeocoder.geocode(@bar.full_address) if @bar.geocoded?
  end

  def submit
    if @bar.submit!
      Gabba::Gabba.new("UA-750037-13", "#{current_site.subdomain ? current_site.subdomain : "www"}.buddybeers.com").event("Merchants", "Creation", @bar.name) if Rails.env.production?
      redirect_to confirm_bar_url(@bar), {:notice => t("bars.submit.success")}
    else
      redirect_to confirm_bar_url(@bar), {:error => t("bars.submit.error")}
    end
  end

  # AJAX
  # TODO: return JSON instead
  def get_bars_for_city
    @bars = []
    unless params[:id].blank?
      city = City.find(params[:id])
      site = params[:site_id] ? Site.find(params[:site_id]) : current_site
      @bars = city.bars.active.for_site(site)
    end
    render :partial => "shared/bars"
  end

  # AJAX to display bar in bar details div
  def update_bar_details
    @bar = params[:id].present? ? Bar.find(params[:id]) : nil
    render :partial => "ious/bar_detail"
  end

  # AJAX for generating quantity range on new iou form
  def get_voucher_limit_for_select_from_bar
    @range = (1..10)
    unless params[:id].blank?
      bar = Bar.find(params[:id])
      if bar.customer_voucher_limit > 0
        @range = (1..bar.customer_voucher_limit)
      end
    end
    render :partial => "shared/quantity"
  end

  protected

  def get_bar
    @bar = Bar.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    other_locale = I18n.locale == :de ? :en : :de
    bar = I18n.with_locale(other_locale) do
      Bar.find(params[:id])
    end
    redirect_to bar, :locale => other_locale, :status => :moved_permanently
  end

  def add_city_if_missing
    if params[:bar][:city_id].blank? and params[:new_city_name].present? and !params[:bar][:country_id].blank?
      params[:bar][:city_id] = City.find_or_create_by_name_and_country_id(:name => params[:new_city_name], :country_id => params[:bar][:country_id]).id
    end
  end
end
