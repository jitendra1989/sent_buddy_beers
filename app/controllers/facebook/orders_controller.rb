class Facebook::OrdersController < Facebook::BaseController
  
  #before_filter :authenticate_user!
  # before_filter :set_redirect_url_for_oauth, :only => [:check]
  before_filter :require_fb_user, :except => [:check]
  before_filter :initialize_fb_graph, :except => [:check]
  before_filter :get_fb_friends, :only => [:new, :create]
  
  def index
    @sent_ious = current_user.sent_ious.paginate(:page => params[:sent_page], :per_page => 6)
    @received_ious = current_user.received_ious.paginate(:page => params[:received_page], :per_page => 6)

    @sent_ious_count = current_user.sent_ious.sum(:quantity)
    @received_ious_count = current_user.sent_ious.sum(:quantity)
    # //Get all app requests for user
    #   $request_url ="https://graph.facebook.com/" .
    #     $user_id .
    #     "/apprequests?" .
    #     $access_token;
    #   $requests = file_get_contents($request_url);    
    
    # apprequest_url = "https://graph.facebook.com/#{current_user.facebook_uid}/apprequests"
    #   result = HTTParty.get(apprequest_url + "?access_token=" + URI.encode(current_user.fb_access_token_for(current_site))).body
    
    current_user.received_facebook_requests.closable.each do |fb_request|
      fb_request.close!
    end
  end
  
  def new
    @iou = Iou.new
    @price = Price.includes(:bar, :beer).find(params[:price_id]) if params[:price_id]
    if params[:bar_id] or @price.present?
      @bar = @price.present? ? @price.bar : Bar.find(params[:bar_id])
    end
  end
  
  def create
    @iou = Iou.new(params[:iou]) do |iou|
      iou.sender = current_user
      iou.site = current_site
    end
    
    if @iou.price.present?
      @price = @iou.price 
      @bar = @price.bar 
    end

    respond_to do |format|
      if @iou.save
        flash[:notice] = t("ious.create.real.success")
        format.html { redirect_to edit_facebook_order_url(@iou) }
      else
        flash[:error] = t("ious.create.error")
        @iou.errors.each do |attr, msg| 
          flash[:error] += "<br />#{t("facebook.orders.create.errors.no_user")}" if "recipient_facebook_uid" == attr.to_s
          flash[:error] += "<br />#{I18n.t(attr.to_s, :scope => [:activerecord, :attributes, :iou], :default => attr.to_s.humanize)} #{msg}" unless ["recipient_email", "recipient_phone", "recipient_facebook_uid", "cents"].include?(attr.to_s)
        end
        format.html { render :new }
        format.xml  { render :xml => @iou.errors }
      end
    end
  end
  
  def edit 
    @iou = Iou.find(params[:id])
    if @iou.paid?
      redirect_to facebook_order_url(@iou)
    else
      @user = current_user
    end
  end
  
  # Redirected here after successfull virtual currency sale
  def show
    @iou = Iou.find(params[:id])
    expire_page :controller => 'home', :action => 'index'
  end
  
  def check
    @order = Iou.find(params[:id])
    
    # do_order_sign_in unless user_signed_in?
    
    # if user is logged into fb and authorized
    if user_signed_in?

      # check if voucher recipient is the same as logged in user
      if @order.recipient == current_user

        # close and delete the request id from fb?
        @order.facebook_request.close! if @order.facebook_request.try(:open)

        # show the voucher code
        @validity = true
        # render(:check) and return

      # if voucher recipient is not the same as logged in user  
      else        
        flash[:error] = "Sorry, you've clicked on a link for someone else's voucher. If you'd like your own beer why not buy youself one?"
        redirect_to(new_facebook_order_url) and return
      end
    else
      @validity = false
      # render('facebook/home/redirect_to_oauth') and return
    end

  end
  
# private
#   def set_redirect_url_for_oauth
#     @oauth = Koala::Facebook::OAuth.new(current_site.facebook_app_id, current_site.facebook_app_secret, "http://apps.facebook.com/#{current_site.facebook_app_url}/?order_id=#{params[:id]}")
#     @oauth_url = @oauth.url_for_oauth_code(:permissions => ["email", "publish_stream"])
#   end
#   
#   def do_order_signin  
#     # AUTHORIZE USER FROM SIGNED REQUEST
#     if params[:signed_request] 
#       signed_request = @oauth.parse_signed_request(params[:signed_request])
#   
#       # IF THE USER IS AUTHORIZED
#       if signed_request['user_id']
#         token = signed_request['oauth_token']
#         uid = "me"
#       end
#     else
#       fb_cookie = @oauth.get_user_info_from_cookies(cookies) 
#     
#       # IF THE USER IS AUTHORIZED
#       if fb_cookie and fb_cookie["access_token"]
#         token = fb_cookie['access_token']
#         uid = fb_cookie["uid"]
#       end
#     end
#   
#     if (signed_request and signed_request['user_id']) or (fb_cookie and fb_cookie["access_token"])
#       @graph = Koala::Facebook::GraphAPI.new(token)
#       @fb_user = @graph.get_object(uid)
#       data = {"extra" => {"user_hash" => @fb_user}, "credentials" => {"token" => token}}
#       user = User.find_for_facebook_oauth(data, current_site)
#       sign_in(user)
#     end
#   end
  
end
