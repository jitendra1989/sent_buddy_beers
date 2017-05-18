class Beer < ActiveRecord::Base
  belongs_to :brand

  has_many :ious
  has_many :group_drinks
  has_many :prices

  validates_presence_of :name
  #validates_presence_of :brand_id #cannot create a beer and a brand at once when this is validated

  accepts_nested_attributes_for :brand, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }

  def to_s; name || "beer" end

  def link_to_brand(brand)
    self.update_attribute(:brand_id, brand.id)
  end
end
