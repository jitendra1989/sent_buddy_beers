class AddContactPhoneNumberToBar < ActiveRecord::Migration
  def self.up
    add_column :bars, :contact_phone_number, :string
  end

  def self.down
    remove_column :bars, :contact_phone_number
  end
end
