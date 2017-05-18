class AddPendingBarInformation < ActiveRecord::Migration
  def self.up
    add_column :bars, :contact_name, :string
    add_column :bars, :lead, :string
    add_column :bars, :contact_email, :string
  end

  def self.down
    remove_column :bars, :contact_name
    remove_column :bars, :lead
    remove_column :bars, :contact_email
  end
end
