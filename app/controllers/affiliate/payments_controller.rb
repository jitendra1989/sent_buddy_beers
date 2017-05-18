class Affiliate::PaymentsController < Affiliate::BaseController
  def index
    @payments = current_user.payments
  end

  def show
    @payment = current_user.payments.find(params[:id])
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "#{t("affiliate.payments.show.title", :number => @payment.id)}", :layout => "pdf.haml", :show_as_html => !params[:debug].blank?
      end
    end
  rescue
    flash[:error] = t("global.access_denied")
    redirect_to affiliate_payments_url
  end
end
