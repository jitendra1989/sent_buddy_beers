class AddPromotionalToIou < ActiveRecord::Migration
  def self.up
    add_column :ious, :promotional, :boolean, :null => false, :default => false
    add_index :ious, :promotional
  end

  def self.down
    remove_column :ious, :promotional
  end
end
