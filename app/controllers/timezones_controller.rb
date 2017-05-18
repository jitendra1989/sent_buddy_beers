class TimezonesController < ApplicationController
 def time_zone
   time_zone = params[:time_zone]

   time_zone = ActiveSupport::TimeZone[time_zone]

   time_zone = ActiveSupport::TimeZone["UTC"] unless time_zone

   session[:time_zone_name] = time_zone.name if time_zone

   render :text => session[:time_zone_name]
 end
end