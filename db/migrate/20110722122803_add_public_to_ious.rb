class AddPublicToIous < ActiveRecord::Migration
  def self.up
    add_column :ious, :public, :boolean, :default => true, :null => false
    add_index :ious, :public
  end

  def self.down
    remove_index :ious, :public
    remove_column :ious, :public
  end
end
