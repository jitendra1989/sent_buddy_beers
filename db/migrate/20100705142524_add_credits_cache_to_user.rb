class AddCreditsCacheToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :credits_cache, :string, :default => "0", :null => false
  end

  def self.down
    remove_column :users, :credits_cache
  end
end
