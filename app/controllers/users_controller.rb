class UsersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index]
  
  def index
    if params.has_key?(:q)
      @users = User.like(params[:q])
      render :json => @users.uniq.collect{ |f| {:id => f.id, :name => f.to_s, :login => f.login, :img_url => f.avatar(:tiny), :email => f.email} } 
    else
      deny_access
    end
  end
  
  def button
    @user = User.find(params[:id])
    if params[:name]
      if params[:name].to_s == "true"
        @name = @user.to_s 
      else
        @name = params[:name]
      end
    else
      @name =  ""#I18n.t("users.button.me")
    end
    @price = Price.includes(:bar, :beer).find(params[:price_id]) if params[:price_id]
    @drink = params[:drink] ? params[:drink] : @price.present? ? @price.name : I18n.t("users.button.beer")
    
    @url_options = {:user_id => @user.id}
    if @price
      @url_options.merge!({:price_id => @price.id, :bar_id => @price.bar_id}) 
    elsif params[:location_id] and @bar = Bar.find(params[:location_id])
      @url_options.merge!({:bar_id => @bar.id})
    end
    render :layout => nil
  end
  
end
