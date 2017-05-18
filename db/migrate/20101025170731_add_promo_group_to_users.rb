class AddPromoGroupToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :promotion_group, :string
    
    add_index :users, :promotion_group
  end

  def self.down
    remove_column :users, :promotion_group
  end
end
