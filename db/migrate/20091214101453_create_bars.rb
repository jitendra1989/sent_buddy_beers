class CreateBars < ActiveRecord::Migration
  def self.up
    create_table :bars do |t|
      t.string :name
      t.string :address
      t.string :city
      t.string :country
      t.integer :affiliate_id
      t.string :token
      t.string :default_currency, :limit => 3, :default => "EUR"
      t.decimal :lat, :precision => 15, :scale => 10
      t.decimal :lng, :precision => 15, :scale => 10
      t.string :phone_number
      t.text :description
      t.string :logo_file_name
      t.string :logo_content_type
      t.integer :logo_file_size
      t.datetime :logo_updated_at

      t.timestamps
    end

    add_index :bars, :address
    add_index :bars, :city
    add_index :bars, :country
    add_index :bars, :name
    add_index :bars, :affiliate_id
  end

  def self.down
    drop_table :bars
  end
end
