class Employment < ActiveRecord::Base
  belongs_to :user
  belongs_to :bar
  
  validates_presence_of :bar, :user
  validates_uniqueness_of :user_id, :scope => :bar_id
  
  after_create :notify_employee
  
  def notify_employee
    Notifier.notify_employee(self).deliver
  end
end
