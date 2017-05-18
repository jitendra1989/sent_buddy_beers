class CreateBeverages < ActiveRecord::Migration
  def self.up
    create_table :beverages do |t|
      t.string :name

      t.timestamps
    end
    
    add_index :beverages, :name
    
    beverage = Beverage.new(:name => "beer")
    beverage.save!
  end

  def self.down
    drop_table :beverages
  end
end
