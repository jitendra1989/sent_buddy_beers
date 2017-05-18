class Corporates::SessionsController < Devise::SessionsController
  #before_filter :require_corporate, :except => [:new, :create]
  #prepend_before_filter :require_no_authentication, :only => [:new, :create]
  layout 'corporate_sign_up_in'
  
  def create
    resource = Corporate.find_by_email(params[:corporate][:email])
    if resource && resource.authenticate(params[:corporate][:email], params[:corporate][:password])
      session[:corporate_id] = resource.id
      set_flash_message :notice, :signed_in
      sign_in_and_redirect(resource_name, resource)
    else
      flash.now.alert = "Invalid email or password"
      render "new"
    end
  end

  def destroy
    signed_in = signed_in?(resource_name)
    session.delete(:corporate_id) unless session[:corporate_id].blank?
    sign_out_and_redirect(resource_name)
    set_flash_message :notice, :signed_out if signed_in
  end
  
protected 
  def after_sign_in_path_for(resource)
    edit_corporate_registration_url
  end

  def after_sign_out_path_for(resource_or_scope)
    session.delete(:corporate_id) unless session[:corporate_id].blank?
    new_corporate_session_url
  end
end
