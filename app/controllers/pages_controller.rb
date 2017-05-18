class PagesController < ApplicationController
  layout :set_page_layout

  # GET /pages/1
  # GET /pages/1.xml
  def show
    if params[:id].to_i >= 1 #strings (slugs) will be 0. ids will be greater than 0
      @page = Page.find_by_id(params[:id])
      translation = @page.translations.where(:locale => I18n.locale).try(:first)
    else  
      translation = PageTranslation.find(params[:id])
      @page = translation.page
    end
    
    if !@page.sites.include?(current_site) or !@page.published?
      raise ActionController::RoutingError.new('Not Found')
    end
    
    if translation and translation.locale.to_sym != I18n.locale
      alt_translations = PageTranslation.where(:page_id => @page.id, :locale => I18n.locale)
      if alt_translations.present?
        redirect_to page_url(alt_translations.first.slug, :locale => I18n.locale) 
      else
        flash.now[:error] = t("pages.show.errors.language_missing", :other_locale => translation.locale.upcase)
        @noindex = true
      end
    end  
  end
  
  def set_page_layout
    layout = "application"
    if params[:id].to_s == "about" || (params[:id].to_s.split("--")[0] == "about")
      layout = "buddy_about"
    end
    if params[:id].to_s == "privacy" || (params[:id].to_s.split("--")[0] == "privacy")
      layout = "new_application"
    end
    return layout
  end

end
