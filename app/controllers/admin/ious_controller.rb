class Admin::IousController < Admin::BaseController
  respond_to :html

  def new
    @iou = Iou.new
    respond_with :admin, @iou
  end

  def create
    @iou = Iou.new(params[:iou]) do |iou|
      iou.sender = current_user
      iou.status = "valid"
      iou.company_promotional = true
    end

    if @iou.save
      @iou.paid!
      flash[:notice] = t("admin.ious.create.success")
    end
    respond_with :admin, @iou, :location => admin_root_path
  end
end
