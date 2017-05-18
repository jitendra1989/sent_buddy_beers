class Site < ActiveRecord::Base
  PROHIBITED_SUBDOMAINS = %w(www pop pop3 smtp mail ftp)
  SUBDOMAIN_REGEXP = /^([a-z0-9_\-]+)$/i

  has_many :bar_sites
  has_many :bars, :through => :bar_sites, :readonly => false
  has_and_belongs_to_many :pages
  has_many :ious
  has_many :credit_events

  validates :name, :presence => true
  validates :code_name, :presence => true, :uniqueness => true, :format => SUBDOMAIN_REGEXP
  validates :subdomain,
            :presence => {:unless => proc { |site| site.subdomain.nil? }},
            :format => {:with => SUBDOMAIN_REGEXP, :allow_nil => true},
            :uniqueness => true,
            :exclusion => PROHIBITED_SUBDOMAINS
  validates :domain, :presence => true, :uniqueness => true

  attr_accessible :name, :code_name, :domain, :subdomain, :facebook_app_id, :facebook_app_secret
  attr_readonly :code_name
  
  # Getting cache errors as per: http://stackoverflow.com/questions/6391855/rails-cache-error-in-rails-3-1-typeerror-cant-dump-hash-with-default-proc
  # after_save :expire_cache

  scope :without_default, where("sites.subdomain IS NOT NULL")
  scope :for, lambda { |user| where(:id => user.site_ids) if user.site_admin? }

  def self.find_for_domains(domain, subdomain)
    site = Site.default

    if domain != site.domain
      Site.find_by_domain(domain)
    elsif subdomain
      Site.find_by_subdomain(subdomain) || site
    else
      site
    end
  end

  def self.default
    # Rails.cache.fetch('default_site') do
      # logger.debug("!!!!!!!!! Searching for default site !!!!!!!!!!!!")
      Site.find_by_subdomain!(nil)
    # end
  end
  
  # def expire_cache
  #     Rails.cache.write('default_site', Site.find_by_subdomain!(nil))
  #   end
end
