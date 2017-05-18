class Affiliate::PricesController < Affiliate::BaseController
  before_filter :get_bar, :only => [:index, :create, :edit, :update, :destroy]
  before_filter :get_price, :only => [:edit, :update, :destroy]

  def index
    @menu = @bar.prices
    @price = @bar.prices.new(:amount => 0)
  end

  def create
    if params[:beer] and params[:beer][:name].present? and params[:beer][:brand_id].present?
      find_or_create_beer(params[:beer])
      params[:price][:beer_id] = @beer.id
    end
    #Seems we have to force currency
    params[:price][:amount] += " #{params[:price][:currency]}" if params[:price].key?(:amount) and params[:price].key?(:currency)
    @price = @bar.prices.build(params[:price])
    if @price.save
      flash[:notice] = t("affiliate.prices.create.success")
      redirect_to affiliate_bar_prices_url(@bar)
    else
      flash[:error] = t("affiliate.prices.create.error")
      render :action => :index
    end
  end

  def edit
  end

  def update
    if @price.update_attributes(params[:price])
      flash[:notice] = t("affiliate.prices.update.success")
      redirect_to affiliate_bar_prices_url(@bar)
    else
      flash[:error] = t("affiliate.prices.update.error")
      render :action => :edit
    end
  end

  def destroy
    if @price.destroy()
      flash[:notice] = t("affiliate.prices.destroy.success")
    else
      flash[:error] = t("affiliate.prices.destroy.error")
    end
    redirect_to affiliate_bar_prices_url(@bar)
  end

  protected
    def get_bar
      @bar = Bar.find(params[:bar_id])
    end

    def get_price
      @price = Price.find(params[:id])
    end
end