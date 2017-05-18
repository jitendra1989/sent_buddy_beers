class AddTrackingToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :referrer, :string
    add_column :users, :registration_layout, :string
  end

  def self.down
    remove_column :users, :referrer
    remove_column :users, :registration_layout
  end
end
