class BarSite < ActiveRecord::Base
  belongs_to :bar
  belongs_to :site

  validates_presence_of :bar, :site
  validates_uniqueness_of :site_id, :scope => :bar_id
end
