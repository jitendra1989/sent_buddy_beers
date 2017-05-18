class AddAdditionalBarFields < ActiveRecord::Migration
  def self.up
    add_column :bars, :percent_cut, :integer, :default => 70
    add_column :bars, :percent_expired_cut, :integer, :default => 100
    add_column :bars, :active, :boolean, :default => false
    
    Bar.all.each{|b| b.update_attribute(:active, true)}
  end

  def self.down
    remove_column :bars, :percent_cut
    remove_column :bars, :percent_expired_cut
    remove_column :bars, :active
  end
end
