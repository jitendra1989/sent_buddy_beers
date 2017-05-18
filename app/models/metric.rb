class Metric < ActiveRecord::Base
  
  belongs_to :user
  
  validates :name, :presence => true
  validates :value, :presence => true
  
  scope :achieved, where('achieved_at IS NOT NULL')
  
end
