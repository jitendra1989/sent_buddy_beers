class CountriesController < ApplicationController
  def get_countries_for_site
    @countries = []
    unless params[:id].blank?
      @countries = Country.with_active_bars.with_bars_for_site(params[:id]).uniq
    end
    render :partial => "shared/countries"
  end
end
