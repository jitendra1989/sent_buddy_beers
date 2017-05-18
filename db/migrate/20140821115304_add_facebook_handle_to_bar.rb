class AddFacebookHandleToBar < ActiveRecord::Migration
  def self.up
    add_column :bars, :facebook_handle, :string
  end

  def self.down
    remove_column :bars, :facebook_handle
  end
end
