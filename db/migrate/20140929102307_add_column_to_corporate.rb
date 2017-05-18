class AddColumnToCorporate < ActiveRecord::Migration
  def self.up
    add_column :corporates, :company_name, :string
    add_column :corporates, :no_of_employees, :string
    add_column :corporates, :phone_number, :string
    add_column :corporates, :company_logo, :string
  end

  def self.down
    remove_column :corporates, :company_logo
    remove_column :corporates, :phone_number
    remove_column :corporates, :no_of_employees
    remove_column :corporates, :company_name
  end
end
