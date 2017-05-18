class HomeController < ApplicationController

  has_mobile_fu
  has_no_mobile_fu_for :index, :privacy, :impresum, :about, :press, :terms, :subscribe, :startups_business, :business_perks, :white_label_program

  def index
    @email_invitation = EmailInvitation.new
    @activity = Iou.where(:id => Iou.with_unique_sender).public.for_site_ids(current_site.id).recent.limit(30)
    #render :layout => "apps" if current_site.code_name == "buddybeers"
    render :layout => "home_buddydrinks" if current_site.code_name == "buddybeers"
    
  end

  def privacy
    pages = Page.live.for_site(current_site).like("privacy")
    if pages.present?
      redirect_to page_url(pages.first.slug)
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def impressum
    pages = Page.live.for_site(current_site).like("impressum")
    if pages.present?
      redirect_to page_url(pages.first.slug)
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end
  
  def business_perks
    render :layout => "corporate_program"
  end
  
  def white_label_program
    render :layout => "corporate_program"
  end
  
  def about
    pages = Page.live.for_site(current_site).like("about")
    if pages.present?
      redirect_to page_url(pages.first.slug)
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end
  
  def press
  end
  
  def terms
    pages = Page.live.for_site(current_site).like("terms")
    if pages.present?
      redirect_to page_url(pages.first.slug)
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end
  
  def iphone
  end
  
  def apps
    @email_invitation = EmailInvitation.new
    @activity = Iou.where(:id => Iou.with_unique_sender).public.for_site_ids(current_site.id).recent.limit(30)
    respond_to do |format|
      format.html { render :layout => "get_app_buddydrinks" }
      format.mobile
    end
  end
  
  def subscribe
    # {"id"=>"c124cf732c", "web_id"=>1013706, "name"=>"Notify of CB iPhone Launch DE"
    # {"id"=>"16bcae853d", "web_id"=>1013702, "name"=>"Notify of CB iPhone Launch EN"
    email = params[:email]
    if email.present? 
      email = email.strip
      if email.match(Devise.email_regexp)
        gb = Gibbon::API.new("4d33aaab5917dc47cb8f166c3f92c3ed-us1")
        response = gb.list_subscribe({:id => (I18n.locale.to_s == "de" ? "c124cf732c" : "16bcae853d"), :email_address => email, :update_existing => true})
        if response.inspect == "true"
          render :text => "OK", :status => 200
        else
          render :text => "ERROR", :status => 500
        end
      else
        render :text => "ERROR", :status => 500
      end
    else
      render :text => "ERROR", :status => 500
    end
  end
  
  def contact_send
    Notifier.contect_us(params).deliver
    redirect_to :back
  end
  
  def information_send
    Notifier.get_information(params).deliver
    redirect_to :back
  end
end
