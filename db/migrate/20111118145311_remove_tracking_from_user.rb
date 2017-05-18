class RemoveTrackingFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :referrer
    remove_column :users, :registration_layout
  end

  def self.down
    add_column :users, :referrer, :string
    add_column :users, :registration_layout, :string
  end
end
