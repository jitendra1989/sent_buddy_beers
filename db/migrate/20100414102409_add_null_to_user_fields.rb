class AddNullToUserFields < ActiveRecord::Migration
  def self.up
    change_column :users, :language, :string, :limit => 5, :default => "en", :null => false
  end

  def self.down
    change_column :users, :language, :string, :limit => 5, :default => "en", :null => true
  end
end
