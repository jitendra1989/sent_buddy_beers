class IousController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :confirm, :confirm_payment]
  before_filter :get_iou, :only => [:show, :pay, :update, :confirm, :completed]
  before_filter :require_iou_owner, :only => [:show]
  before_filter :update_iou_fields, :only => [:pay]
  layout "new_application", :only =>[:new, :index, :create, :send_group_drinks, :pay, :confirm_payment, :completed, :show]
  def index
    @sent_ious_sum = current_user.sent_ious
    @sent_ious = current_user.sent_ious.paginate(:page => params[:page], :per_page => 3)
    #@received_ious = current_user.received_ious
    @received_ious_sum = current_user.received_group_drinks
    @received_ious = current_user.received_group_drinks.paginate(:page => params[:page], :per_page => 3)
  end

  def new
    @iou = Iou.new
    @price = Price.includes(:bar, :beer).find(params[:price_id]) if params[:price_id]
    if params[:bar_id] or @price.present?
      @bar = @price.present? ? @price.bar : Bar.find(params[:bar_id])
    end
    if params[:user_id]
      @recipient = User.find(params[:user_id])
      @iou.recipient_name = @recipient.name
      @iou.recipient_email = @recipient.email
      @iou.recipient_id = @recipient.id
      @iou.group_drinks.build(:recipient_id => @recipient.id, :recipient_email=> @recipient.email, :recipient_name => @recipient.get_name)
    elsif params[:friend_name]
      @iou.recipient_name = params[:friend_name]
      @iou.group_drinks.build(:recipient_name => params[:friend_name])
    else
      @iou.group_drinks.build
    end
  end

  alias_method :send_group_drinks, :new

  def show
    @drinks = @iou.group_drinks.received_drinks(current_user.id) if @iou.present?
  end

  def create
    @iou = Iou.new(params[:iou]) do |iou|
      iou.sender = current_user
      iou.site = current_site
    end

    @iou.recipient_name = params[:dynamicrecipientemail] if @iou.recipient_name.blank?

    if @iou.price.present?
      @price = @iou.price
      @bar = @price.bar
    end
    respond_to do |format|
      if @iou.save
        flash[:notice] = t("ious.create.real.success")
        format.html { redirect_to pay_iou_url(@iou) }
      else
        flash[:error] = t("ious.create.error")
        logger.debug("!!!!!!!!!! #{@iou.errors.inspect}")
        #@iou.errors.reject!{ |k, v| [:cents, :recipient_facebook_uid].include?(k) }.full_messages.each do |msg|
          #flash[:error] += "<br />#{msg}".html_safe
        #end
        format.html {
          @iou.group_drinks.build  unless @iou.group_drinks.present?
          if request.env["HTTP_REFERER"].include?("send_group_drinks")
            @bar = nil
            @price = nil
            render :send_group_drinks
          else
            render :new
          end
        }
        format.xml  { render :xml => @iou.errors }
      end
    end
  end

  def destroy
  end

  def pay
    if @iou.paid?
      redirect_to completed_iou_url(@iou)
    else
      @user = current_user
      if @iou.beer.present? and @iou.bar.present?
        @price = Price.find_by_beer_id_and_bar_id(@iou.beer_id, @iou.bar_id)
      end
    end
  end

  # show the confirm page on the payment screen
  # this will prompt the user to buy the iou with buddy bucks
  def confirm
    @user = current_user
    @return_uri = params[:return_uri]
    @credit_event = CreditEvent.new(:user => current_user, :iou => @iou, :amount => @iou.total_cents, :currency => @iou.group_drinks.first.currency, :provider => "BuddyBucks", :site_id => @iou.site_id, :virtualamount => @iou.price_in_bucks, :commtype => "PURCHASE")
    render :layout => 'buddybucks'
  end

  # Redirected here after successfull sale using virtual currency
  # used to POST here from paypal
  def confirm_payment
    @iou = Iou.find(params[:item_number] || params[:id])
    expire_page :controller => 'home', :action => 'index'
  end

  def completed
    unless @iou.paid?
      flash[:error] = t("ious.completed.error")
      redirect_to pay_iou_url(@iou)
    end
  end

  protected

  def get_iou
    @iou = params[:code].present? ? Iou.find_by_token(params[:code]) : Iou.find(params[:id])
  end

  def update_iou_fields
    @iou.update_attributes(:quantity => @iou.total_quantity, :currency =>  @iou.group_drinks.first.currency, :cents => @iou.calculate_total.to_f * 100)
  end

  def get_user
    @user = current_user
  end

  def require_iou_owner
    if (params[:code] == @iou.token) or (current_user and current_user.admin?) or (current_user and (@iou.group_drinks.map(&:recipient_id).include?(current_user.id)))
      return true
    else
      store_location
      flash[:notice] = t("global.require_user").html_safe
      redirect_to (current_user ? user_url(current_user) : new_user_session_url)
      return false
    end
  end
end
