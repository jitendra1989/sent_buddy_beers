class AddMoreBarContactInfoToBar < ActiveRecord::Migration
  def self.up
    add_column :bars, :mailing_address, :text
    add_column :bars, :contact_time, :string
    add_column :bars, :signup_notes, :text
  end

  def self.down
    remove_column :bars, :mailing_address
    remove_column :bars, :contact_time
    remove_column :bars, :signup_notes
  end
end
