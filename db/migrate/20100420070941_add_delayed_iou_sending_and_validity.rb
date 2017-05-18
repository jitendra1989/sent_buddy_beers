class AddDelayedIouSendingAndValidity < ActiveRecord::Migration
  def self.up
    add_column :bars, :delivery_lead_time, :integer, :default => 0, :null => false
    add_column :ious, :valid_at, :datetime
    add_column :bars, :internet_enabled, :boolean
    
    add_index :bars, :delivery_lead_time
    add_index :ious, :valid_at
  end

  def self.down
    remove_column :bars, :delivery_lead_time
    remove_column :ious, :valid_at
    remove_column :bars, :internet_enabled
  end
end
