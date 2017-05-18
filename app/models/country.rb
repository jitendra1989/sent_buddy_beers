class Country < ActiveRecord::Base
  has_many :bars, :order => "name ASC"
  has_many :cities, :order => "name ASC"

  validates_presence_of :iso, :name, :printable_name, :iso3, :numcode
  validates_uniqueness_of :iso, :name, :iso3, :numcode
  validates_numericality_of :numcode

  scope :with_active_bars, joins(:bars).where(:bars => {:active => true})
  scope :with_bars_for_site, lambda { |site| joins(:bars => :sites).where(:sites => { :id => site }) }
end
