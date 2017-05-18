class Facebook::LocationsController < Facebook::BaseController
  
  before_filter :initialize_fb_graph, :if => :current_user
  
  def index
    @bars = current_site.bars.active
    if params[:origin]
      @bars = @bars.geocoded.within(params[:origin][:distance] || 50, :origin => params[:origin][:location])
      if @bars.empty?
        flash.now[:error] = t("bars.search.no_results", :location => params[:origin][:location], :distance => params[:origin][:distance] || 50)
        @bars = current_site.bars.active
      end
    end
  rescue Geokit::Geocoders::GeocodeError
    flash.now[:error] = t("bars.search.address_not_found", :location => params[:origin][:location])
    @bars = current_site.bars.active
  end
  
  def show
    @bar = current_site.bars.find(params[:id])
    @feed = @bar.ious.recent.first(15)
    @geocoords = Geokit::Geocoders::MultiGeocoder.geocode(@bar.full_address) if @bar.geocoded?
  end
  
  # AJAX to display bar in bar details div
  def update_location_details
    @bar = params[:id].present? ? Bar.find(params[:id]) : nil
    render :partial => "facebook/locations/location_detail"
  end
  
end
