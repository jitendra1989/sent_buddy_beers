class BeersController < ApplicationController
  
  # AJAX for generating beers from brands
  def get_beers_for_brand
    brand = Brand.find(params[:brand_id])
    @beers = brand.beers
    render :partial => "shared/beers"
  end
  
  # AJAX for adding a new beer
  def add_beer
    @beer = Beer.new(params[:beer])
    @beer.save
    brand = Brand.find(params[:beer][:brand_id])
    @beers = brand.beers
    render :partial => "shared/beers"
  end
  
end
