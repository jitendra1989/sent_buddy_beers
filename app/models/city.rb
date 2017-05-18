class City < ActiveRecord::Base

  has_many :bars, :order => "name ASC"
  belongs_to :country

  validates :name, :presence => true, :unique_in_country => true
  validates :country_id, :presence => true

  scope :with_active_bars, joins(:bars).where(:bars => {:active => true})
  scope :with_bars_for_site, lambda { |site| joins(:bars => :sites).where(:sites => { :id => site }) }
end
