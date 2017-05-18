class Admin::SiteAdminsController < Admin::BaseController
  respond_to :html

  def index
    @site_admins = SiteAdmin.all
    respond_with :admin, @site_admins
  end

  def new
    @site_admin = SiteAdmin.new
    @site_admin.emails.build
    respond_with :admin, @site_admin
  end

  def create
    @site_admin = SiteAdmin.new(params[:site_admin])
    flash[:notice] = "You done did it!" if (@site_admin.save && @site_admin.confirm!)
    respond_with :admin, @site_admin, :location => admin_site_admins_path
  end

  def edit
    @site_admin = SiteAdmin.find(params[:id])
    respond_with :admin, @site_admin
  end

  def update
    @site_admin = SiteAdmin.find(params[:id])
    flash[:notice] = "You done did it!" if @site_admin.update_attributes(params[:site_admin])
    respond_with :admin, @site_admin, :location => admin_site_admins_path
  end

  def destroy
    @site_admin = SiteAdmin.find(params[:id])
    if @site_admin.destroy
      flash[:notice] = "Killed that fool!"
    else
      flash[:error] = "Botched job."
    end
    respond_with :admin, @site_admin
  end
end
