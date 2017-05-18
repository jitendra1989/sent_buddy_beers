class Brand < ActiveRecord::Base
  belongs_to :beverage
  has_many :beers, :order => :name
  has_many :ious
  has_many :group_drinks

  validates_presence_of :name
  validates_uniqueness_of :name

  accepts_nested_attributes_for :beers, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }

  def to_s; name || "" end
end
