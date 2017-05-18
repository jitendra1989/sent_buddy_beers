class AddNotifiedToIous < ActiveRecord::Migration
  def self.up
    add_column :ious, :notified, :boolean, :default => false
  end

  def self.down
    remove_column :ious, :notified
  end
end
