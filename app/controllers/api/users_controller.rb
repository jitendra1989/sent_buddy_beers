class Api::UsersController < Api::BaseController
  before_filter :authenticate_user_for_api!, :get_user

  def show_1
    render :json => {:success => true, :user => jsonify_user(@user) }
  end
  
  def update_1
    if @user.update_attributes(params[:resource]) # have to use resource param here because :user throws and error with auth.
      @user.update_attribute(:avatar, params[:avatar]) unless params[:avatar].blank?
      render :json => {:success => true, :user => jsonify_user(@user) }
    else
      render :json => {:success => false, :errors => @user.errors.full_messages }
    end
  end
  
  def last_locations_1
    @ious = Iou.paid.find(:all, :conditions => ["recipient_id = ? OR sender_id = ?", @user.id, @user.id], :order => "created_at DESC", :limit => 25, :include => :bar)
    if @ious.present?
      render :json => {:success => true, :locations => @ious.collect{ |i| i.bar }.uniq.first(5).collect{ |b| jsonify_location(b) } }
    else
      render :json => {:success => false, :errors => [t("api.v1.users.errors.no_locations")]}
    end
  end

private

  def jsonify_user(user)
    {  :id => @user.id, :auth_token => @user.authentication_token, 
       :employee => @user.can_redeem_vouchers?,
       :name => @user.to_s, :currency => @user.credits, 
       'outstandingVouchers' => @user.vouchers.redeemable.length, 
       'lastLogin' => @user.last_sign_in_at.strftime("%H:%M %d %b %Y"), 
       :image => @user.avatar.file? ? @user.avatar(:thumb) : "http://#{current_site.domain}/images/sites/#{current_site.code_name}/users/thumb/missing.png",
       :facebook_id => @user.facebook_uid,
       :primary_email => @user.primary_email,
       :other_emails => @user.display_all_email,
       :login => @user.login,
       :phone_number => @user.phone_number }
  end
  
end
