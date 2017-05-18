class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.integer :affiliate_id
      t.string :affiliate_name
      t.boolean :paid, :default => false, :null => false
      t.integer :cents, :default => 0, :null => false
      t.datetime :beginning_at, :null => false
      t.datetime :ending_at, :null => false
      t.datetime :paid_at
      t.string :currency
      t.text :notes
      t.text :admin_notes

      t.timestamps
    end
    
    add_index :payments, :affiliate_id
    add_index :payments, :paid
  end

  def self.down
    drop_table :payments
  end
end
