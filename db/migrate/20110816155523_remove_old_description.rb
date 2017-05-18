class RemoveOldDescription < ActiveRecord::Migration
  def self.up
    remove_column :bars, :old_description
  end

  def self.down
    add_column :bars, :old_description, :text
  end
end
