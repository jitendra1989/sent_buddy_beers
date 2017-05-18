class RemoveVolumeAndDrinkTypeFromBeers < ActiveRecord::Migration
  def self.up
    remove_column :beers, :drink_type_id
    remove_column :beers, :volume
  end

  def self.down
    add_column :beers, :drink_type_id, :integer
    add_column :beers, :volume, :string, :length => 20
    add_index :beers, :drink_type_id
  end
end
