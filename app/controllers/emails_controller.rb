class EmailsController < ApplicationController
  before_filter :authenticate_user!, :only => [:activate]
  before_filter :require_no_user, :only => [:add]

  def activate
    if email = Email.find_by_token_and_user_id(params[:activation_code], current_user.id)
      email.pending = false
      if email.save
        current_user.sync_pending_ious
        flash[:notice] = t("emails.activate.success")
      else
        flash[:error] = t("emails.activate.error")
      end
    else
      flash[:error] = t("emails.activate.not_found")
    end
    redirect_to edit_user_registration_url(current_user)
  end
end
