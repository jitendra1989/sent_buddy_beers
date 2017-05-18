class CreateVoucherLists < ActiveRecord::Migration
  def self.up
    create_table :voucher_lists do |t|
      t.integer :bar_id, :null => false
      t.integer :cents, :null => false
      t.string :currency, :null => false, :default => "EUR"

      t.boolean :closed, :null => false, :default => false
      t.boolean :archived, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :voucher_lists
  end
end
