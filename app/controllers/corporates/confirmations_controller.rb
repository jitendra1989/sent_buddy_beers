class Corporates::ConfirmationsController < Devise::ConfirmationsController
  layout 'corporate_sign_up_in'
  
  def show
    resource = Corporate.where(:confirmation_token => params[:confirmation_token]).first
    if resource.confirm!
      session[:corporate_id] = resource.id
      sign_in resource_name, resource, :bypass => true
      redirect_to edit_corporate_registration_url
    else
      new_corporate_session_url
    end
  end
end
