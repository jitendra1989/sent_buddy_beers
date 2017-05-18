class Facebook::UsersController < Facebook::BaseController
  
  # facebook_grant_permissions_url
  def grant_permissions
    @user = User.find(params[:id])
    if @user and app_cred = FacebookAppCredential.find_by_user_id_and_site_id_and_app_id(@user.id, current_site.id, current_site.facebook_app_id)
      render app_cred.update_attribute(:permissions => params[:permissions]) ? {:text => "OK", :status => 200} : {:text => "ERROR", :status => 500}
    end
  end
  
end
