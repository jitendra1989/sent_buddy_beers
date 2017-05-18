class RemoveDeliveryLeadTimeFromBars < ActiveRecord::Migration
  def self.up
    remove_column :bars, :delivery_lead_time
    remove_column :ious, :valid_at
  end

  def self.down
    remove_column :bars, :delivery_lead_time, :integer, :default => 0, :null => false
    add_column :ious, :valid_at, :datetime
  end
end
