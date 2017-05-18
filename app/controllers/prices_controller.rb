class PricesController < ApplicationController
  
  before_filter :get_bar, :except => [:get_prices_for_select_from_bar]
  before_filter :redirect_if_active_or_not_pending, :except => [:show, :get_prices_for_select_from_bar]
  
  def new 
    @price = @bar.prices.new(:amount => 0)
    @menu = @bar.prices
  end
  
  def create
    if params[:beer] and params[:beer][:name].present? and params[:beer][:brand_id].present?
      find_or_create_beer(params[:beer])
      params[:price][:beer_id] = @beer.id
    end
    @price = @bar.prices.new(params[:price])
    if @price.save
      flash[:notice] = t("affiliate.prices.create.success")
    else
      flash[:error] = t("affiliate.prices.create.error")
    end
    redirect_to new_bar_price_url(@bar)
  end
  
  def destroy
    @price = Price.find(params[:id])
    if @price.destroy()
      flash[:notice] = t("affiliate.prices.destroy.success")
    else
      flash[:error] = t("affiliate.prices.destroy.error")
    end
    redirect_to new_bar_price_url(@bar)
  end
  
  def show
    @price = @bar.prices.find(params[:id])
    render :layout => 'open_graph_object'
  end
  
  # AJAX for generating prices on new iou form
  def get_prices_for_select_from_bar
    @prices = []
    unless params[:id].blank?
      bar = Bar.find(params[:id])
      @prices = bar.prices
    end
    render :partial => "shared/prices"
  end

protected
  
  def get_bar
    @bar = Bar.find(params[:bar_id])
  end
  
  # def find_or_create_beer(params)
  #   @beer = Beer.find_by_name_and_brand_id(params[:name], params[:brand_id])
  #   if @beer.nil?
  #     @beer = Beer.new(params)
  #     @beer.save
  #   end
  # end
  
end
