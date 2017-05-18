class Api::OrdersController < Api::BaseController

  before_filter :authenticate_user_for_api!

  def create_1

    if params[:order].has_key?(:id) and params[:order][:id].present?
      @order = Iou.find(params[:order][:id])
      @order.attributes = params[:order].reject{ |k,v| !@order.attribute_present?(k.to_s) }
    else
      parameter = {"memo"=> params["order"]["memo"], "bar_id"=> params["order"]["bar_id"], "group_drinks_attributes"=>{"0"=>{"recipient_phone"=> params["order"]["recipient_phone"], "recipient_name"=>params["order"]["recipient_name"], "quantity"=> params["order"]["quantity"], "recipient_email"=>params["order"]["recipient_email"], "price_id"=>params["order"]["price_id"], "recipient_facebook_uid" => params["order"]["recipient_facebook_uid"], "recipient_id" => params["order"]["recipient_id"]}}}

      @order = Iou.new(parameter) do |order|
        order.sender = current_user
        order.site = current_site
      end
    end

    # Turning off orders (1 May 2013). Uncomment to turn back on.

    @json = @order.save ? {:success => true, :order => jsonify_order(@order) } : {:success => false, :errors => @order.errors.full_messages }

    if params[:payment_method].present? and (params[:payment_method] == "buddybucks")
          if current_user.credits.to_i >= @order.price_in_bucks
            if @order.persisted?
              @order.paid! unless @order.paid?
              post_to_facebook(@order)
              CreditEvent.create(:user => current_user, :iou => @order, :amount => @order.cents, :currency => @order.currency, :provider => "BuddyBucks", :site_id => @order.site_id, :virtualamount => @order.price_in_bucks, :commtype => "PURCHASE (API)")
              @json = {:success => true, :order => jsonify_order(@order.reload), :user => {:credits => current_user.reload.credits}}
            end
          else
            if @json.has_key?(:errors)
              @json[:errors] << t("api.v1.orders.errors.not_enough_currency")
            else
              @json = {:success => false, :errors => [t("api.v1.orders.errors.not_enough_currency")]}
            end
          end
        end

    render :json => @json

    #render :json => {:success => false, :errors => ["New orders are not being accepted at this time. Mor"]}
  end

end
