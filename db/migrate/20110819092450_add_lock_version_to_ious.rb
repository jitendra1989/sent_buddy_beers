class AddLockVersionToIous < ActiveRecord::Migration
  def self.up
    add_column :ious, :lock_version, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :ious, :lock_version
  end
end
