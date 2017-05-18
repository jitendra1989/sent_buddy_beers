class CreateDrinkTypes < ActiveRecord::Migration
  def self.up
    create_table :drink_types do |t|
      t.integer :beverage_id
      # Single Table Inheritance
      t.string :type

      t.timestamps
    end
    
    add_index :drink_types, :beverage_id
    
    Bottle.create(:beverage_id => Beverage.find_by_name("beer"))
    Draught.create(:beverage_id => Beverage.find_by_name("beer"))
  end

  def self.down
    drop_table :drink_types
  end
end
