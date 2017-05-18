class CreateCities < ActiveRecord::Migration
  def self.up
    create_table :cities do |t|
      t.string :name
      t.integer :country_id
      t.timestamps
    end
    
    add_index :cities, :name
    add_index :cities, :country_id
    
    remove_column :bars, :city
    add_column :bars, :city_id, :integer
    add_index :bars, :city_id
    
    country = Country.find_by_iso("DE")
    
    city = City.new(:name => "Berlin", :country_id => country.id)
    city.save
    
    Bar.all.each{ |b| b.update_attribute(:city_id, city.id) }
  end

  def self.down
    drop_table :cities
    
    remove_column :bars, :city_id
    add_column :bars, :city, :string
  end
end
