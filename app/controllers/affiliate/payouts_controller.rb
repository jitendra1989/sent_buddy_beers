class Affiliate::PayoutsController < Affiliate::BaseController
  def index
    @payouts = current_user.payouts
  end

  def new
    @payout = current_user.payouts
    @payout = current_user.payouts.build if @payout.blank?
  end

  def edit
    @payout = Payout.find(params[:id])
  end

  def update
    @payout = Payout.find(params[:id])
    #~# If You want to save any values((name, address) || email) according to payment_type
    #~ if params[:payout][:payment_type] == 'cheque'
      #~ @payout.email = nil
      #~ params[:payout][:email] = nil
    #~ else
      #~ @payout.name = nil
      #~ @payout.address = nil
      #~ params[:payout][:name] = nil
      #~ params[:payout][:address] = nil
    #~ end
    #~ @payout.save
    if @payout.update_attributes(params[:payout])
      flash[:notice] = "Payout has been successfully Updated."
      redirect_to affiliate_payouts_url
    else
      flash[:error] = "Some thing wrong on updating. Please try again with proper information"
      render 'edit'
    end
  end

  def create
    @payout = current_user.payouts.new(params[:payout])
    if @payout.save
      flash[:notice] = "Payout has been successfully Created."
      redirect_to affiliate_payouts_url
    else
      flash[:error] = "Some thing wrong. Please try again with proper information"
      render 'new'
    end
  end

  def outstanding_payouts
    @total_vouchers =   current_user.bars.includes(:vouchers=>:paid_vouchers).where("paid_vouchers.is_paid =?", false).map{|bar| bar.vouchers.redeemed.order("vouchers.token asc")}.flatten
    @vouchers = @total_vouchers.paginate(:page => params[:page], :per_page => 20)
  end

  def pay
    paid_vouchers_status = false
    total_vouchers = get_redeemed_vouchers
    voucher_ids = total_vouchers.map(&:id)
    if PaidVoucher.where(:voucher_id => voucher_ids).blank?
      paid_vouchers_status = total_vouchers.includes(:paid_vouchers).where("paid_vouchers.is_paid =?", true).blank?
    end
    unless total_vouchers.blank?
      unless paid_vouchers_status
        admin = Admin.find 133 #oboukottaya@buddydrinks.com
        total_amount = total_vouchers.map{|voucher| voucher.amount.to_f}.sum
        amount_with_currency = total_vouchers.last.amount.currency.symbol.to_s+''+total_amount.to_f.to_s
        PaidVoucherDetail.create(:affiliate_id => current_user.id, :no_of_redeemed_vouchers => total_vouchers.count, :amount => amount_with_currency, :date => Time.now, :mode => current_user.payouts.last.payment_type)
        total_vouchers.each do |voucher|
          voucher.paid_vouchers.create(:paid_at => Time.now, :is_paid => true)
        end
        Notifier.payment_request_alert(current_user, total_amount.to_f, admin, total_vouchers).deliver
        flash[:notice] = "Payment Request Alert successfully email sent to Admin"
        redirect_to affiliate_payouts_url
      else
        flash[:error] = "Voucher does not exist for pay"
        redirect_to affiliate_outstanding_payouts_url
      end

    else
      flash[:error] = "Voucher does not exist for pay"
      redirect_to affiliate_outstanding_payouts_url
    end
  end

  def paid_vouchers
    payments = current_user.paid_voucher_details.order('created_at DESC')
    @paid_voucher_details = payments.paginate(:page => params[:page], :per_page => 20)
  end

  private
    def get_redeemed_vouchers
      current_user.bars.includes(:vouchers).map{|bar| bar.vouchers.redeemed.order("vouchers.token asc")}.flatten
    end
end
