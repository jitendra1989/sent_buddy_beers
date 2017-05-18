class AddFieldsToBar < ActiveRecord::Migration
  def self.up
    add_column :bars, :mon_opening_time, :string
    add_column :bars, :mon_closing_time, :string

    add_column :bars, :tue_opening_time, :string
    add_column :bars, :tue_closing_time, :string

    add_column :bars, :wed_opening_time, :string
    add_column :bars, :wed_closing_time, :string

    add_column :bars, :thu_opening_time, :string
    add_column :bars, :thu_closing_time, :string

    add_column :bars, :fri_opening_time, :string
    add_column :bars, :fri_closing_time, :string

    add_column :bars, :sat_opening_time, :string
    add_column :bars, :sat_closing_time, :string

    add_column :bars, :sun_opening_time, :string
    add_column :bars, :sun_closing_time, :string
  end

  def self.down
    remove_column :bars, :mon_opening_time
    remove_column :bars, :mon_closing_time

    remove_column :bars, :tue_opening_time
    remove_column :bars, :tue_closing_time

    remove_column :bars, :wed_opening_time
    remove_column :bars, :wed_closing_time

    remove_column :bars, :thu_opening_time
    remove_column :bars, :thu_closing_time

    remove_column :bars, :fri_opening_time
    remove_column :bars, :fri_closing_time

    remove_column :bars, :sat_opening_time
    remove_column :bars, :sat_closing_time

    remove_column :bars, :sun_opening_time
    remove_column :bars, :sun_closing_time
  end
end
