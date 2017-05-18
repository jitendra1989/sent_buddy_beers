class Api::PricesController < Api::BaseController
  
  before_filter :get_location
  
  def index_1
    if @location.prices.present?
      render :json => {:success => true, :prices => @location.prices.collect { |p| jsonify_price(p) }}
    else
      render :json => {:success => false, :errors => [t("api.v1.prices.errors.empty")]}
    end
  end
  
  protected
    def get_location
      @location = Bar.find(params[:location_id])
    end
  
end
