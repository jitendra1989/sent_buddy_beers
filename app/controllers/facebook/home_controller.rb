class Facebook::HomeController < Facebook::BaseController
  before_filter :find_fb_user_and_sign_in, :except => [:channel, :redirect_to_oauth]
  
  def index
    if params[:order_id]
      redirect_to(check_facebook_order_url(params[:order_id])) and return
    else
      @email_invitation = EmailInvitation.new
      @activity = Iou.where(:id => Iou.with_unique_sender).public.for_site_ids(current_site.id).recent.limit(30)
    end
  end
  
  def channel
    render :layout => false
  end
  
  def redirect_to_oauth
  end
  
end
