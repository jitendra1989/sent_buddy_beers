class CreateIous < ActiveRecord::Migration
  def self.up
    create_table :ious do |t|
      t.integer :recipient_id
      t.string  :recipient_name
      t.integer :sender_id
      t.string  :sender_name
      t.integer :beverage_id
      t.integer :brand_id
      t.integer :beer_id
      t.integer :bar_id
      t.string  :status, :default => "sent"
      t.string  :token
      t.integer :order_id
      t.string  :memo
      t.integer :quantity
      t.boolean :virtual, :default => false
      t.boolean :paid, :default => false
      t.boolean :redeemed, :default => false
      t.datetime :expires_at
      t.string :redemption_token
      
      t.timestamps
    end
    
    add_index :ious, :recipient_id
    add_index :ious, :sender_id
    add_index :ious, :beverage_id
    add_index :ious, :brand_id
    add_index :ious, :beer_id
    add_index :ious, :bar_id
    add_index :ious, :status
    add_index :ious, :token
    add_index :ious, :order_id
  end

  def self.down
    drop_table :ious
  end
end
