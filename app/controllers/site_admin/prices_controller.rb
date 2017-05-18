class SiteAdmin::PricesController < SiteAdmin::BaseController
  respond_to :html

  def index
    @prices = bar.prices
    @price = bar.prices.new(:amount => 0)
    respond_with :site_admin, bar, @prices
  end

  def create
    #Seems we have to force currency
    params[:price][:amount] += " #{params[:price][:currency]}" if params[:price].key?(:amount) and params[:price].key?(:currency)
    @price = bar.prices.build(params[:price])
    if @price.save
      flash[:notice] = t("affiliate.prices.create.success")
    else
      flash[:error] = t("affiliate.prices.create.error")
    end
    redirect_to site_admin_bar_prices_url(@bar)
  end

  def edit
    respond_with :site_admin, bar, price
  end

  def update
    if price.update_attributes(params[:price])
      flash[:notice] = t("affiliate.prices.update.success")
    else
      flash[:error] = t("affiliate.prices.update.error")
    end
    respond_with :site_admin, bar, price, :location => site_admin_bar_prices_url(bar)
  end

  def destroy
    if price.destroy
      flash[:notice] = t("affiliate.prices.destroy.success")
    else
      flash[:error] = t("affiliate.prices.destroy.error")
    end
    respond_with :site_admin, bar, price
  end

  protected

  def bar
    @bar ||= Bar.for_site_admin(current_user).find(params[:bar_id])
  end

  def price
    @price ||= bar.prices.find(params[:id])
  end
end
