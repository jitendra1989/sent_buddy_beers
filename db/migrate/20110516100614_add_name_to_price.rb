class AddNameToPrice < ActiveRecord::Migration
  def self.up
    add_column :prices, :name, :string
    add_column :prices, :description, :text
    add_column :prices, :volume, :string
    add_column :prices, :drink_type_id, :integer
    add_column :prices, :beverage_id, :integer
    
    Price.all.each do |price|
      drink_type = price.try(:beer).try(:drink_type_id) ? DrinkType.find(price.try(:beer).try(:drink_type_id)) : nil
      price.name = [price.try(:beer).try(:brand).try(:name), price.try(:beer).try(:name), drink_type.nil? ? "" : drink_type.to_s, price.try(:beer).try(:volume)].join(" ").strip
      price.volume = price.try(:beer).try(:volume)
      price.drink_type_id = price.try(:beer).try(:drink_type_id)
      price.beverage_id = 1
      price.save(false)
    end
    
    add_index :prices, :drink_type_id
  end

  def self.down
    remove_column :prices, :name
    remove_column :prices, :description
    remove_column :prices, :volume
    remove_column :prices, :drink_type_id
    remove_column :prices, :beverage_id
  end
end
