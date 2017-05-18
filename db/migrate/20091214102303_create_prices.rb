class CreatePrices < ActiveRecord::Migration
  def self.up
    create_table :prices do |t|
      t.integer :beer_id
      t.integer :bar_id
      t.integer :cents
      t.string :currency, :default => "EUR"

      t.timestamps
    end
    
    add_index :prices, :beer_id
  end

  def self.down
    drop_table :prices
  end
end
