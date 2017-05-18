class AddVolumeToBeers < ActiveRecord::Migration
  def self.up
    add_column :beers, :volume, :string, :length => 20
  end

  def self.down
    remove_column :beers, :volume
  end
end
