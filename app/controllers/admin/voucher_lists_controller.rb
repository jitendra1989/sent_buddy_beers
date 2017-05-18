class Admin::VoucherListsController < Admin::BaseController
  before_filter :get_bar
  
  def show
    @list = @bar.voucher_lists.find(params[:id])
    @previous_list = @list.previous
    respond_to do |format|
      format.html
      format.pdf { render :pdf => "#{t("affiliate.bars.voucher_list.pdf_file_name")}_#{@list.cents}_#{@list.id}", :layout => "pdf.haml", :show_as_html => !params[:debug].blank?}
    end
  end
  
  protected
    def get_bar
      @bar = Bar.find(params[:bar_id])
    end
end
