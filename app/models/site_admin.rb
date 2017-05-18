class SiteAdmin < User
  has_many :site_admin_sites
  has_many :sites, :through => :site_admin_sites
end
