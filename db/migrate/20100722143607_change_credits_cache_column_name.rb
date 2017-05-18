class ChangeCreditsCacheColumnName < ActiveRecord::Migration
  def self.up
    rename_column :users, :credits_cache, :credits
  end

  def self.down
    rename_column :users, :credits, :credits_cache
  end
end
