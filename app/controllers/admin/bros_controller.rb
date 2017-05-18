class Admin::BrosController < Admin::BaseController
  def index
    @users = Bro.all.paginate(:page => params[:page], :per_page => 50)
  end
end
