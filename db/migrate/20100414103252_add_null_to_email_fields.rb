class AddNullToEmailFields < ActiveRecord::Migration
  def self.up
    change_column :emails, :primary, :boolean, :default => false, :null => false
    change_column :emails, :email, :string, :null => false
  end

  def self.down
    change_column :emails, :primary, :boolean, :default => false, :null => true
    change_column :emails, :email, :string, :null => true
  end
end
