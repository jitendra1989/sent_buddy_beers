class DrinkType < ActiveRecord::Base
  belongs_to :beverage
  has_many :prices

  validates_presence_of :beverage_id

  def to_s
    self.class.name.to_s
  end
end
