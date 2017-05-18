class AddTwitterHandleToBars < ActiveRecord::Migration
  def self.up
    add_column :bars, :twitter_handle, :string
  end

  def self.down
    remove_column :bars, :twitter_handle
  end
end
