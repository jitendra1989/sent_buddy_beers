class AddDrinkTypeIdToBeers < ActiveRecord::Migration
  def self.up
    add_column :beers, :drink_type_id, :integer
    
    add_index :beers, :drink_type_id
  end

  def self.down
    remove_column :beers, :drink_type_id
  end
end
