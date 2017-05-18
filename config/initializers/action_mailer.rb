class ActionMailer::Base
  def current_site
    Thread.current[:current_site]
  end

  def default_url_options_with_subdomain
    subdomain = current_site.subdomain || ""
    subdomain += "." unless subdomain.empty?
    host = [subdomain, default_url_options_without_subdomain[:host]].join
    default_url_options_without_subdomain.merge(:host => host)
  end

  alias_method_chain :default_url_options, :subdomain
end
