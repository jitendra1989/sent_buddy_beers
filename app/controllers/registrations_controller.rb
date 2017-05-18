class RegistrationsController < Devise::RegistrationsController
  layout :choose_layout
  
  # GET /resource/sign_up
  def new
    build_resource
    resource.emails.build
    if params[:ref] and params[:ref] == "sponsorpay"
      # Store the id of the current metric in the session for A/B testing
      session[:registration_layout] = Metric.create(:name => "registration_layout", :value => (Metric.where(:name => "registration_layout").try(:last).try(:value) == "right") ? "top" : "right").id unless session[:registration_layout]
      session[:registration_ref] = Metric.create(:name => "referrer", :value => "sponsorpay").id unless session[:registration_ref]
    end
    @referrer = Metric.find(session[:registration_ref]) if session.has_key?(:registration_ref)
    @registration_layout = Metric.find(session[:registration_layout]) if session.has_key?(:registration_layout)
    render_with_scope :new
  end
  
  # POST /resource
  def create
    build_resource

    if resource.save
      
      Metric.find(session[:registration_layout]).update_attributes(:user_id => resource.id, :achieved_at => DateTime.now()) if session.has_key?(:registration_layout)
      Metric.find(session[:registration_ref]).update_attributes(:user_id => resource.id, :achieved_at => DateTime.now()) if session.has_key?(:registration_ref)
      
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        #respond_with resource, :location => redirect_location(resource_name, resource)
        respond_with(resource, :location => redirect_location(resource_name, resource)) do |format|
          format.json do
            Gabba::Gabba.new("UA-750037-13", "#{current_site.subdomain ? current_site.subdomain : "www"}.buddybeers.com").event("Users", "Signup", "classic mobile") if Rails.env.production?
            render :json => {:success => true, :user => {:id => resource.id, :auth_token => resource.authentication_token, :employee => resource.can_redeem_vouchers?}}
          end
        end
      else
        set_flash_message :notice, :inactive_signed_up, :reason => resource.inactive_message.to_s if is_navigational_format?
        expire_session_data_after_sign_in!
        #respond_with resource, :location => after_inactive_sign_up_path_for(resource)
        respond_with(resource, :location => after_inactive_sign_up_path_for(resource)) do |format|
          format.json do 
            Gabba::Gabba.new("UA-750037-13", "#{current_site.subdomain ? current_site.subdomain : "www"}.buddybeers.com").event("Users", "Signup", "classic mobile") if Rails.env.production?
            render :json => {:success => true, :alert => I18n.t("devise.failure.unconfirmed")}
          end
        end
      end
    else
      clean_up_passwords(resource)
      # respond_with_navigational(resource) do
      #         resource.emails.build
      #         render_with_scope :new
      #       end
      respond_with(resource) do |format|
        format.json { render :json => {:success => false, :errors => resource.errors.full_messages } }
        format.any(*navigational_formats) do
          resource.emails.build if resource.emails.blank?
          render_with_scope(:new)
        end
      end
    end
  end

  # PUT /resource
  def update
    if resource.update_attributes(params[resource_name])
      set_flash_message :notice, :updated
      sign_in resource_name, resource, :bypass => true
      redirect_to after_update_path_for(resource)
    else
      clean_up_passwords(resource)
      render_with_scope :edit
    end
  end
  
  def delete_user_pic
    user = User.find(params[:user_id])
    user_pic = user.delete_pic?
    if user_pic
      flash[:notice] = "User picture has been deleted successfully"
    else
      flash[:notice] = "Some things wrong !!"
    end
    redirect_to edit_user_registration_url(user)
  end

  def create_with_email
    build_resource

    if resource.save
      if resource.confirm!
        set_flash_message :notice, :signed_up
        sign_in resource_name, resource, :bypass => true
        redirect_to ious_url
      else
        set_flash_message :notice, :inactive_signed_up, :reason => resource.inactive_message.to_s
        expire_session_data_after_sign_in!
        redirect_to after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords(resource)
      render_with_scope :new
    end
  end
  
  def create_with_facebook
    data = {"extra" => {"user_hash" => params[:user]}, "credentials" => {"token" => params[:token]}}
    @user = User.find_for_facebook_oauth(data, current_site)
    respond_with(@user) do |format|
      if @user.persisted?
        if params[:user].has_key?(:facebook_permissions)
          app_cred = FacebookAppCredential.find_by_user_id_and_site_id_and_app_id(@user.id, current_site.id, current_site.facebook_app_id)
          app_cred.update_attribute(:permissions, params[:user][:facebook_permissions]) if app_cred
        end
        format.json do
          sign_in(@user)
          Gabba::Gabba.new("UA-750037-13", "#{current_site.subdomain ? current_site.subdomain : "www"}.buddybeers.com").event("Users", "Signup", "facebook mobile") if Rails.env.production?
          render :json => {:success => true, :user => {:id => @user.id, :auth_token => @user.authentication_token, :employee => @user.can_redeem_vouchers?}}
        end
        format.any(*navigational_formats) do
          flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
          sign_in_and_redirect @user, :event => :authentication
        end
      else
        format.json { render :json => {:success => false, :errors => @user.errors.full_messages } }
        format.any(*navigational_formats) do
          session["devise.facebook_data"] = env["omniauth.auth"]
          redirect_to new_user_registration_url
        end
      end
    end
  rescue ActiveRecord::RecordInvalid
    respond_with do |format|
      format.json { render :json => {:success => false, :errors => ["There was an error creating this user. Please make sure email is included in the user hash."] } }
      format.any(*navigational_formats) do
        session["devise.facebook_data"] = env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    end
  end
  
  def complete
    Gabba::Gabba.new("UA-750037-13", "#{current_site.subdomain ? current_site.subdomain : "www"}.buddybeers.com").event("Users", "Signup", "classic web") if Rails.env.production?
  end

  protected
  def build_resource(hash=nil)
    hash ||= params[:customer] || {}
    self.resource = Customer.new_with_session(hash, session)
    self.resource.sign_up_site = current_site
  end

  def after_update_path_for(resource)
    edit_user_registration_path
  end

  def after_sign_up_path_for(resource)
    users_sign_up_complete_path
  end
  
  def after_inactive_sign_up_path_for(resource)
    users_sign_up_complete_path
  end

  # TODO: remove this once this bug is fixed:
  # https://github.com/plataformatec/devise/issues#issue/806
  def authenticate_scope!
    send(:"authenticate_#{resource_name}!", true)
    if signed_in?(resource_name)
      self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    end
  end
  
 private
  def choose_layout
    return "buddy_login" if ["new", "create"].include?(action_name)
    return "new_application" if ["edit", "update", "complete"].include?(action_name)
  end
end
