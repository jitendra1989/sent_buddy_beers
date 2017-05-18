class Admin::SitesController < Admin::BaseController
  respond_to :html

  def index
    @sites = Site.all
    respond_with :admin, @sites
  end

  def show
    @site = Site.find(params[:id])
    respond_with :admin, @site
  end
  
  def new
    @site = Site.new
    respond_with :admin, @site
  end
  
  def create
    @site = Site.create(params[:site])
    respond_with :admin, @site
  end

  def edit
    @site = Site.find(params[:id])
    respond_with :admin, @site
  end

  def update
    @site = Site.find(params[:id])
    flash[:notice] = "Site updated successfully." if @site.update_attributes(params[:site])
    respond_with :admin, @site
  end
end
