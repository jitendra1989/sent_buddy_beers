class BrandsController < ApplicationController
  def index 
    @brands = Brand.all
    if params[:q]
      @brands = Brand.with_name_like(params[:q])
    end
    render :json => @brands.uniq.collect{ |f| {:id => f.id, :name => f.name }} 
  end
  
  # AJAX
  def add_brand
    if params[:brand]
      @brand = Brand.find_or_create_by_beverage_id_and_name(:beverage_id => params[:brand][:id], :name => params[:brand][:name]) 
      @brand.save
    end
    render :text => @brand.name
  end
end
