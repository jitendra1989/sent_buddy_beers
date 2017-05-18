class SiteAdminSite < ActiveRecord::Base
  belongs_to :site_admin
  belongs_to :site

  validates_presence_of :site_admin, :site
  validates_uniqueness_of :site_id, :scope => :site_admin_id
end
