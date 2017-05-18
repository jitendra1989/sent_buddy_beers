class SessionsController < Devise::SessionsController
  prepend_before_filter :require_no_authentication, :only => [ :new, :create, :create_with_email ]

  # GET /resource/sign_in
  def new
    resource = build_resource
    clean_up_passwords(resource)
    respond_with(resource, stub_options(resource)) do |format|
      format.json { render :json => {:success => false, :errors => [t("devise.sessions.login_failed")] } }
      format.any(*navigational_formats){ render_with_scope(:new) }
    end
  end

  # POST /resource/sign_in
  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
    #set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    respond_with(resource, :location => redirect_location(resource_name, resource)) do |format|
      format.json { render :json => {:success => true, :user => {:id => resource.id, :auth_token => resource.authentication_token, :employee => resource.can_redeem_vouchers?}} }
    end
  end

  # GET /resource/sign_out
  def destroy
    signed_in = signed_in?(resource_name)
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message :notice, :signed_out if signed_in

    # We actually need to hardcode this, as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.json { render :json => {:success => true} }
      format.any(*navigational_formats) { redirect_to after_sign_out_path_for(resource_name) }
      format.all do
        method = "to_#{request_format}"
        text = {}.respond_to?(method) ? {}.send(method) : ""
        render :text => text, :status => :ok
      end
    end
  end

  def create_with_email
    resource = warden.authenticate(:scope => resource_name)

    if resource
      set_flash_message(:notice, :signed_in) if is_navigational_format?
      sign_in(resource_name, resource)
      resource.emails.create!(:email => params[:email][:email], :pending => false)
      respond_with resource, :location => params[:return_to]
    else
      redirect_to params[:return_to], :alert => t("devise.sessions.not_sign_in")
    end
  end

  protected

  def after_sign_in_path_for(resource)

    if resource.type == 'Affiliate'
      affiliate_root_path(resource)
    else
      edit_user_registration_url(resource)
    end
    # case current_user
    #     when Admin then admin_root_url
    #     when SiteAdmin then site_admin_root_url
    #     when Affiliate, Bro then affiliate_root_url
    #     else new_iou_url
    #     end
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_url
  end
end
