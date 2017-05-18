class Affiliate::EmploymentsController < Affiliate::BaseController
  
  before_filter :get_bar
  
  def index
    @employments = @bar.employments
    @employment = @bar.employments.new
  end
  
  def create
    employment_count = 0
    params[:employment][:user_id].split(",").each do |id|
      employment_count += 1 if @bar.employments.create(:user_id => id, :active => true)
    end
    if employment_count > 0 
      flash[:notice] = t("affiliate.employments.create.success")
    else
      flash[:error] = t("affiliate.employments.create.error")
    end
    redirect_to affiliate_bar_employments_url(@bar)
  end
  
  def destroy
    @employment = @bar.employments.find(params[:id])
    if @employment.destroy()
      flash[:notice] = t("affiliate.employments.destroy.success")
    else
      flash[:error] = t("affiliate.employments.destroy.error")
    end
    redirect_to affiliate_bar_employments_url(@bar)
  end
  
  protected

  def get_bar
    @bar = @bars.find(params[:bar_id])
  end
  
end
