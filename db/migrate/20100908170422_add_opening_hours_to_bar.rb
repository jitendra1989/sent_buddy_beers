class AddOpeningHoursToBar < ActiveRecord::Migration
  def self.up
    add_column :bars, :opening_hours, :text
  end

  def self.down
    remove_column :bars, :opening_hours
  end
end
