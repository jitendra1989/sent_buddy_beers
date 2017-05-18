class CitiesController < ApplicationController
  def get_cities_for_country
    @cities = []
    unless params[:id].blank?
      country = Country.find(params[:id])
      @cities = if current_user.try(:admin?) || current_user.try(:site_admin?)
                  if params[:site_id]
                    country.cities.with_bars_for_site(params[:site_id]).uniq
                  else
                    country.cities.uniq
                  end
                else
                  country.cities.with_active_bars.with_bars_for_site(current_site).uniq
                end
    end
    render :partial => "shared/cities"
  end
end
