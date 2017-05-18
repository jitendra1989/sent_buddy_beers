class AddPendingToBars < ActiveRecord::Migration
  def self.up
    add_column :bars, :pending, :boolean, :default => true, :null => false

    add_index :bars, :pending
    
    Bar.all.each{ |bar| bar.update_attribute(:pending, false) }
  end

  def self.down
    remove_column :bars, :pending
  end
end
