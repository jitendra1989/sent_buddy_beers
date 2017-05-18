class Beverage < ActiveRecord::Base

  has_many :brands
  has_many :ious
  has_many :group_drinks
  has_many :beers, :through => :brands
  has_many :drink_types
  has_many :prices
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  def to_s; name || "" end
  
  def self.default
    Beverage.where("UPPER(name) like ?", "%#{"beer".upcase}%").first
  end
  
end
