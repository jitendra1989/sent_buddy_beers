class CreateVouchers < ActiveRecord::Migration
  def self.up
    create_table :vouchers do |t|
      t.integer :voucher_list_id, :null => false
      t.string :token, :null => false
      t.string :redemption_token, :null => false
      t.integer :bar_id, :null => false
      t.integer :iou_id
      t.boolean :redeemed, :null => false, :default => false

      t.integer :cents, :null => false
      t.string :currency, :null => false, :default => "EUR"

      t.timestamps
    end
    add_index :vouchers, :bar_id
    add_index :vouchers, :voucher_list_id
    add_index :vouchers, [:redeemed, :bar_id]
  end

  def self.down
    drop_table :vouchers
  end
end
