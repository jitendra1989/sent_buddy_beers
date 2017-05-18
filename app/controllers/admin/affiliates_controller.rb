class Admin::AffiliatesController < Admin::BaseController
  before_filter :get_affiliate, :only => [:show, :edit, :update, :destroy]

  def index
    @users = Affiliate.all.paginate(:page => params[:page], :per_page => 50)
  end

  def show
  end

  def new
    @user = Affiliate.new
    @user.emails.build
  end

  def create
    @user = Affiliate.new(params[:affiliate])
    if @user.skip_confirmation! && @user.save
      @user.activate_email
      flash[:notice] = "You done did it!"
      redirect_to admin_affiliate_path(@user)
    else
      flash[:error] = "That ain't right."
      render :action => "new"
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:affiliate])
      flash[:notice] = "You done did it!"
      redirect_to admin_affiliates_path
    else
      flash[:error] = "That ain't right."
      render :action => "edit"
    end
  end

  def destroy
    if @user.destroy()
      flash[:notice] = "Killed that fool!"
      redirect_to admin_affiliates_path
    else
      flash[:error] = "Botched job."
      render :action => "index"
    end
  end

  protected
    def get_affiliate
      @user = Affiliate.find(params[:id])
    end
end