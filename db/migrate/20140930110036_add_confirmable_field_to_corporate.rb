class AddConfirmableFieldToCorporate < ActiveRecord::Migration
  def self.up
    add_column :corporates, :confirmed_at, :datetime
    add_column :corporates, :confirmation_token, :string
    add_column :corporates, :confirmation_sent_at, :datetime
    add_index  :corporates, :confirmation_token, :unique => true
  end

  def self.down
    remove_column :corporates, :confirmed_at
    remove_column :corporates, :confirmation_token
    remove_column :corporates, :confirmation_sent_at
    remove_index  :corporates, :confirmation_token
  end
end
