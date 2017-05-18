class AddPendingToEmails < ActiveRecord::Migration
  def self.up
    add_column :emails, :pending, :boolean, :default => false, :null => false
    add_column :emails, :token, :string
    change_column :emails, :pending, :boolean, :default => true, :null => false
    add_index :emails, :token
  end

  def self.down
    remove_column :emails, :pending
    remove_column :emails, :token
  end
end
