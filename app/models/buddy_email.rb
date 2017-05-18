class BuddyEmail < ActiveRecord::Base
  belongs_to :emailable, :polymorphic => true
  validates_uniqueness_of :email, :case_sensitive => false
end
