class CreatePayouts < ActiveRecord::Migration
  def self.up
    create_table :payouts do |t|
      t.integer :affiliate_id
      t.string :name
      t.string :email
      t.string :address
      t.string :payment_type

      t.timestamps
    end
  end

  def self.down
    drop_table :payouts
  end
end
