class CreateBeers < ActiveRecord::Migration
  def self.up
    create_table :beers do |t|
      t.string :name
      t.integer :brand_id

      t.timestamps
    end
    
    add_index :beers, :name
    add_index :beers, :brand_id
  end

  def self.down
    drop_table :beers
  end
end
