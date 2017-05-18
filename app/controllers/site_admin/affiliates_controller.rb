class SiteAdmin::AffiliatesController < SiteAdmin::BaseController
  respond_to :html

  def index
    @affiliates = Affiliate.all #Affiliate.for_site_admin(current_user)
    respond_with :site_admin, @affiliates
  end

  def show
    @user = affiliate
    respond_with :site_admin, affiliate
  end

  def new
    @affiliate = Affiliate.new
    @affiliate.emails.build
    respond_with :site_admin, @affiliate
  end

  def create
    @affiliate = Affiliate.new(params[:affiliate])
    @affiliate.sign_up_site = current_site
    if (@affiliate.skip_confirmation! && @affiliate.save)
      @affiliate.activate_email
      flash[:notice] = t("site_admin.affiliates.create.success")
    end
    respond_with :site_admin, @affiliate, :location => site_admin_affiliates_path
  end

  def edit
    respond_with :site_admin, affiliate
  end

  def update
    flash[:notice] = t("site_admin.affiliates.update.success") if affiliate.update_attributes(params[:affiliate])
    respond_with :site_admin, affiliate
  end

  def destroy
    if affiliate.destroy
      flash[:notice] = t("site_admin.affiliates.destroy.success")
    else
      flash[:error] = t("site_admin.affiliates.destroy.error")
    end
    respond_with :site_admin, affiliate
  end

  protected

  def affiliate
    @affiliate ||= Affiliate.find(params[:id]) #Affiliate.for_site_admin(current_user).find(params[:id])
  end
end
