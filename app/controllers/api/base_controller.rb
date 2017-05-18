class Api::BaseController < ApplicationController
  skip_before_filter :authenticate

  include ActionView::Helpers::NumberHelper

  # Versioned API From: http://www.starkiller.net/2011/03/17/versioned-api-1/
  # The entirety of our API method invocation logic resides in the ApiContoller class (in app/controllers/api/base_controller.rb).
  # This acts as a base class from which all other API controllers inherit from and provides automatic registration of API methods.
  # To act as a an API method registry, we set up a couple of class variables and define a few class methods.

  @@versions = {}
  @@registered_methods = {}

  class << self
    alias_method :original_inherited, :inherited

    # The inherited method is called whenever the ApiController class is inherited by an API subclass.
    # This method will load the API subclass and parse through the actions, extracting the method names
    # and versions, and add each method to the registry. The inherited routine also adds an empty method
    # for each API method declared; this ensures that the Rails router will appropriately find each
    # method that is called and will pass the request along to the controller object.

    def inherited(subclass)
      original_inherited(subclass)

      load File.join("#{Rails.root}", "app", "controllers",
                     "api", "#{extract_filename(subclass)}")

      subclass.action_methods.each do |method|
        regex = Regexp.new("^(.*)_(\\d+)$")
        if match = regex.match(method)
          key = "#{subclass.to_s}##{match[1]}"
          @@versions[match[2].to_i] = true
          @@registered_methods[key] ||= {}
          @@registered_methods[key][match[2].to_i] = true

          subclass.instance_eval do
            define_method(match[1].to_sym) {}
          end
        end
      end
      subclass.reset_action_methods
    end

    def extract_filename(subclass)
      classname = subclass.to_s.split('::')[1]
      parts = classname.underscore.split('_')
      "#{parts.reject{|c| c == 'controller'}.join('_')}_controller.rb"
    end

    def reset_action_methods
      @action_methods = nil
      action_methods
    end
  end


  def versions
    render :json => @@versions.keys.sort.reverse and return
  end

  def no_api_method
    render :json => {"error" => "The requested method does not exist or is not\
       enabled for the requested API version (v#{params[:version]})"},
       :status => 404 and return
  end


  private
  def protected_actions
    ['versions','no_api_method']
  end

  alias_method :original_process_action, :process_action

  # When the controller receives a request to process an action, a poorly-documented method called
  # process_action is called. We override this method to intercept the action invocation, check the
  # version requested, and map the appropriate action to be called by the original process_action method.
  # The code for this is below, along with a helper method.

  def process_action(method_name, *args)
    method = "no_api_method"
    if protected_actions.include? method_name
      method = method_name
    else
      if params[:version]
        params[:version] = params[:version][1,params[:version].length - 1].to_i
      else
        params[:version] = @@versions.keys.max
      end
      method = find_method(method_name, params[:version])
    end
    original_process_action(method, *args)
  end

  def find_method(method_name, version)
    key = "#{self.class.to_s}##{method_name}"
    versions = @@registered_methods[key].keys.sort

    final_method = 'no_api_method'

    versions.reverse.each do |v|
      if v <= version
        final_method = "#{method_name}_#{v}"
        break
      end
    end

    final_method
  end

  def rescue_from_no_user
    render :json => {:success => false, :errors => [t("api.v1.users.errors.not_found")]}
  end

  def get_user
    @user = current_user rescue rescue_from_no_user
  end

  def photos_for(price, options={})
    [{ :type => 'iphone', :url => price.try(:photo).try(:file?) ? price.photo(:iphone) : "http://#{current_site.domain}/images/sites/#{current_site.code_name}/prices/iphone/missing.png", :width => 55, :height => 55 },
     { :type => 'iphone_retina', :url => price.try(:photo).try(:file?) ? price.photo(:iphone_retina) : "http://#{current_site.domain}/images/sites/#{current_site.code_name}/prices/iphone_retina/missing.png", :width => 110, :height => 110 }]
  end

  def jsonify_price(p, options={})
    { :id => p.id,
      :name => p.name,
      :discounted => p.discounted,
      :currency => p.total.currency.symbol,
      :currency_code => p.total.currency.to_s,
      :cents => p.cents,
      :discounted_cents => p.discounted_cents,
      :cents_virtual => p.cents_virtual,
      :discounted_cents_virtual => p.discounted_cents_virtual,
      :details => p.details,
      :images => photos_for(p)
    }
  end

  def jsonify_location(b, options={})
    base =  {  :id => b.id,
               :name => b.name,
               :image => b.logo.file? ? b.logo(:thumb) : b.gallery.photos.present? ? b.gallery.photos.first.photo(:thumb) : "http://#{current_site.domain}/images/sites/#{current_site.code_name}/bars/thumb/missing.png",
               :address => b.full_address,
               :city => b.city.name,
               :country => I18n.t("countries.#{b.country.printable_name.parameterize("_")}"),
               :lat => b.lat,
               :lng => b.lng,
               :distance => b.respond_to?(:distance) ? sprintf("%.02f km", b.distance) : nil,
               :phone => b.phone_number,
               :detail => b.opening_hours,
               :prices => b.prices.collect { |p| jsonify_price(p) }
            }
    # if options[:version] == 2
    #       base = {'name' => self.name}
    #     end
    base
  end

  def jsonify_order(o, options={})
    {
      :id => o.id,
      :bar_id => o.bar_id,
      :total => number_to_currency(o.total.to_f, :unit => o.total.currency.symbol),
      :virtual_total => o.price_in_bucks,
      :memo => o.memo,
      :price_id => o.try(:group_drinks).try(:last).try(:price_id),
      :price_name => o.try(:group_drinks).try(:last).try(:price_name),
      :quantity => o.try(:group_drinks).try(:last).try(:quantity),
      :recipient_email => o.try(:group_drinks).try(:last).try(:recipient_email),
      :recipient_name => o.try(:group_drinks).try(:last).try(:recipient_name),
      :recipient_phone => o.try(:group_drinks).try(:last).try(:recipient_phone),
      :recipient_facebook_uid => o.try(:group_drinks).try(:last).try(:recipient_facebook_uid),
      :sender_name => o.sender_name,
      :paid => o.paid
    }
  end

  def authenticate_user_for_api!
    unless user_signed_in?
      render :json => {:success => false, :errors => [t("api.v1.users.errors.not_logged_in")]}
    end
  end
end
