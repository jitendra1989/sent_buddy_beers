class ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      set_flash_message :notice, :confirmed
      sign_in(resource_name, resource)
      redirect_to edit_user_registration_url(resource)
    else
      flash[:error] = t("user_activations.no_user", :errors => resource.errors.full_messages.join(", "))
      redirect_to new_user_registration_url
    end
  end
end
