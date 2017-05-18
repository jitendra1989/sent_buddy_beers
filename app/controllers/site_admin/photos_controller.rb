class SiteAdmin::PhotosController < SiteAdmin::BaseController
  respond_to :html

  def index
    respond_with :site_admin, bar, gallery
  end

  def new
    @photo = gallery.photos.new
    respond_with :site_admin, bar, @photo
  end

  def create
    @photo = gallery.photos.new(params[:photo])
    flash[:notice] = t("affiliate.photos.create.success") if @photo.save
    respond_with :site_admin, bar, @photo, :location => site_admin_bar_photos_path(bar)
  end

  def edit
    respond_with :site_admin, bar, photo
  end

  def update
    flash[:notice] = t("affiliate.photos.update.success") if photo.update_attributes(params[:photo])
    respond_with :site_admin, bar, photo, :location => site_admin_bar_photos_path(bar)
  end

  def destroy
    photo.destroy ? (flash[:notice] = t("affiliate.photos.destroy.success")) : (flash[:error] = t("affiliate.photos.destroy.error"))
    respond_with :site_admin, bar, photo, :location => site_admin_bar_photos_path(bar)
  end

  protected

  def bar
    @bar ||= Bar.for_site_admin(current_user).find(params[:bar_id], :include => :gallery)
  end

  def gallery
    @gallery ||= bar.gallery
  end

  def photo
    @photo ||= gallery.photos.find(params[:id])
  end
end
