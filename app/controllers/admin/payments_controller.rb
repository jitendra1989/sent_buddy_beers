class Admin::PaymentsController < Admin::BaseController

  before_filter :get_payment, :only => [:show, :edit, :update, :destroy, :toggle]

  def index
    if params[:payable]
      @payments = Payment.order("beginning_at DESC, affiliate_name").where(:paid => false).where('cents > 0').paginate(:page => params[:page], :per_page => 50)
    else
      @payments = Payment.find(:all, :order => "beginning_at DESC, affiliate_name").paginate(:page => params[:page], :per_page => 50)
    end
    if request.xhr?
      #sleep(10) # make request a little bit slower to see loader :-)
      render :partial => 'shared/payment_table_inside'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @payment.update_attributes(params[:payment])
      flash[:notice] = "Payment updated!"
      redirect_to admin_payment_url(@payment)
    else
      flash[:error] = "Error Updating Payment"
      render :action => 'edit'
    end
  end

  def destroy
    @payment.destroy() ? (flash[:notice] = "Payment Deleted!") : (flash[:error] = "Error")
    redirect_to admin_payments_path
  end

  # AJAX
  def toggle
    @payment.paid ? @payment.update_attribute(:paid, false) : @payment.paid!
    render :nothing => true
  end

protected
  def get_payment
    @payment = Payment.find(params[:id])
  end

end
