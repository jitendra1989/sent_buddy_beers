class AddOutstandingIouCountToBar < ActiveRecord::Migration
  def self.up
    add_column :bars, :outstanding_ious_count, :integer, :null => false, :default => 0
    
    Bar.all.each do |bar|
      bar.outstanding_ious_count = bar.ious.outstanding.length
      bar.save
    end
  end

  def self.down
    remove_column :bars, :outstanding_ious_count
  end
end
