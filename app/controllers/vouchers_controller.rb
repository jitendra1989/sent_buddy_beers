class VouchersController < ApplicationController

  has_mobile_fu

  before_filter :authenticate_user!, :only => [:check, :redeem]
  before_filter :get_voucher_and_iou, :only => [:show]
  before_filter :require_iou_owner, :only => [:show]

  def show
    redirect_to iou_url(@iou, :code => @iou.token)
  end
  
  def check
    render :layout => 'popup'
  end

  def redeem
    # any changes to this method should also be made in the API
    if params[:code].present?
      if current_user.can_redeem_vouchers?
        token = params[:code].gsub(/[^A-Za-z0-9]/, "").first(4).upcase
        code = params[:code].gsub(/[^A-Za-z0-9]/, "").last(2).upcase
        vouchers = current_user.redeemable_vouchers
        if vouchers.present?
          if @voucher = vouchers.find{ |v| v.token == token }
            @voucher.redemption_code = code
            if @voucher.save and @voucher.reload.redeemed?
              @status = {:success => "<span class=\"price\">#{@voucher.amount} #{@voucher.iou.price_name}</span> " + (@voucher.iou.expired? ? t("vouchers.redeem.success_expired", :bar => @voucher.bar.name) : t("vouchers.redeem.success", :bar => @voucher.bar.name))}
            else
              @status = {:error => t("vouchers.redeem.error.unredeemable")}
            end
          else
            @status = {:error => t("vouchers.redeem.error.not_found")}
          end
        else
          @status = {:error => t("vouchers.redeem.error.empty")}
        end
      else
        @status = {:error => t("vouchers.redeem.error.permission_denied")}
      end
    else
      @status = {:error => t("vouchers.redeem.error.no_code")}
    end
    render :check, :layout => 'popup'
  end

  protected

    def get_voucher_and_iou
      @voucher = Voucher.find(params[:id], :include => :iou)
      @iou = @voucher.iou if @voucher.present?
      if @iou.nil?
        flash[:error] = t("ious.show.expired")
        redirect_to root_url
      end
    end

    def require_iou_owner
      if (params[:token] == @voucher.token) or (current_user and current_user.admin?) or (current_user and (current_user.id == @voucher.iou.recipient_id))
        return true
      else
        store_location
        flash[:notice] = t("global.access_denied")
        redirect_to root_url
        return false
      end
    end

end
