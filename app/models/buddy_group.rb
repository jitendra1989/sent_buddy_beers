class BuddyGroup < ActiveRecord::Base
  has_many :buddy_emails, :as => :emailable, :dependent => :destroy
  belongs_to :groupable, :polymorphic => true
  validates_uniqueness_of :name, :case_sensitive => false
end
