class AddNotifiedToEmails < ActiveRecord::Migration
  def self.up
    add_column :emails, :notified, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :emails, :notified
  end
end
