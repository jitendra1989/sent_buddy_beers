class AddBirthdayDateToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :birthday_day, :datetime
  end

  def self.down
    remove_column :users, :birthday_day
  end
end
