# creating versioned api from: http://www.starkiller.net/2011/03/17/versioned-api-1/

class Api::LocationsController < Api::BaseController
  
  def index_1
    @locations = current_site.bars.active
    @locations = @locations.like(params[:q]) if params[:q]
    @locations = @locations.geocoded.within(params[:distance] || 500, :origin => ActiveSupport::Inflector.transliterate(params[:origin])).order('distance asc') if params[:origin]
    @locations = @locations.paginate(:page => params[:page], :per_page => 10)
    if @locations.present?
      render :json => {:success => true, :locations => @locations.map{ |b| jsonify_location(b) }, :total_pages => @locations.total_pages, :current_page => @locations.current_page }
    else
      @locations = current_site.bars.active.paginate(:page => params[:page], :per_page => 10) if @locations.empty?
      render :json => {:success => false, :errors => [t("api.v1.locations.errors.not_found")], :locations => @locations.map{ |b| jsonify_location(b) }, :total_pages => @locations.total_pages, :current_page => @locations.current_page }
    end
  end
  
end
