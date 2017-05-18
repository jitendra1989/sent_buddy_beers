class Admin::UsersController < Admin::BaseController
  before_filter :get_user, :only => [:edit, :update, :show]

  def index
    if params[:query]
      @users = User.includes(:emails).like(params[:query]).uniq
    else
      @users = User.where("users.confirmed_at IS NOT NULL").includes(:emails).order("created_at DESC")
    end
    @users = @users.paginate(:page => params[:page], :per_page => 50)
  end

  def edit
  end

  def update
    user_params = params[:user] || params[:customer] || params[:admin] || params[:affiliate] || params[:bro] || params[:site_admin]
    @user.attributes = user_params
    @user.type = user_params[:type] if user_params[:type] != @user.type
    if @user.save
      flash[:notice] = "User updated!"
      redirect_to admin_users_url
    else
      flash[:error] = "Error. Shit!"
      render :action => 'edit'
    end
  end
  
  def show
  end

  protected
    def get_user
      @user = User.find(params[:id])
    end
end
