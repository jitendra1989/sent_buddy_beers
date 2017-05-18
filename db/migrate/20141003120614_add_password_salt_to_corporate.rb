class AddPasswordSaltToCorporate < ActiveRecord::Migration
  def self.up
    add_column :corporates, :password_salt, :string
  end

  def self.down
    remove_column :corporates, :password_salt
  end
end
