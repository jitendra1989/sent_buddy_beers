class CreateBrands < ActiveRecord::Migration
  def self.up
    create_table :brands do |t|
      t.string :name
      t.integer :beverage_id

      t.timestamps
    end
    
    add_index :brands, :name
    add_index :brands, :beverage_id
  end

  def self.down
    drop_table :brands
  end
end
