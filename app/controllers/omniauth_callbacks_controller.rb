class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_site, current_user)

    if @user.persisted?
      
      #This is for tracking signups via referrers and A/B testing the registration layout
      # Metric.find(session[:registration_ref]).update_attributes(:user_id => @user.id, :achieved_at => DateTime.now()) if session.has_key?(:registration_ref)
      #       Metric.find(session[:registration_layout]).update_attributes(:user_id => @user.id, :achieved_at => DateTime.now()) if session.has_key?(:registration_layout)
      #         
      flash[:notice] = I18n.t("devise.omniauth_callbacks.success", :kind => "Facebook")
      flash[:notice] += "<iframe src=\"http://www2.balao.de/SL2YM?adv_sub=SUB_ID\" scrolling=\"no\" frameBorder=\"0\" width=\"1\" height=\"1\"></iframe>" if @user.created_at.day == Date.today.day
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end
