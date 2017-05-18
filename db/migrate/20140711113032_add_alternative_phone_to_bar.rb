class AddAlternativePhoneToBar < ActiveRecord::Migration
  def self.up
    add_column :bars, :alternative_phone, :string
  end

  def self.down
    remove_column :bars, :alternative_phone
  end
end
