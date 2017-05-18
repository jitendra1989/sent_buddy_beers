class Affiliate::PhotosController < Affiliate::BaseController

  before_filter :get_bar
  before_filter :get_gallery
  before_filter :get_photo, :only => [:edit, :update, :destroy]

  def new
    @photo = @gallery.photos.new
  end

  def create
    @photo = @gallery.photos.new(params[:photo])
    if @photo.save
      flash[:notice] = t("affiliate.photos.create.success")
      redirect_to gallery_affiliate_bar_path(@bar)
    else
      flash[:error] = t("affiliate.photos.create.error")
      render :action => :new
    end
  end

  def edit
  end

  def update
    if @photo.update_attributes(params[:photo])
      flash[:notice] = t("affiliate.photos.update.success")
      redirect_to gallery_affiliate_bar_path(@bar)
    else
      flash[:error] = t("affiliate.photos.update.error")
      render :action => :edit
    end
  end

  def destroy
    @photo.destroy() ? (flash[:notice] = t("affiliate.photos.destroy.success")) : (flash[:error] = t("affiliate.photos.destroy.error"))
    redirect_to gallery_affiliate_bar_path(@bar)
  end

protected
  def get_bar
    @bar = Bar.find(params[:bar_id], :include => :gallery)
  end

  def get_gallery
    @gallery = @bar.gallery
  end

  def get_photo
    @photo = @gallery.photos.find(params[:id])
  end

end
