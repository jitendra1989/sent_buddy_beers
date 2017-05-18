class CreateLineItems < ActiveRecord::Migration
  def self.up
    create_table :line_items do |t|
      t.integer :payment_id
      t.integer :bar_id
      t.integer :iou_id
      t.integer :voucher_id
      t.string :payout_percent
      t.string :status
      t.integer :cents
      t.string :currency
      t.timestamps
    end
    
    add_index :line_items, :payment_id
    add_index :line_items, :bar_id
    add_index :line_items, :iou_id
    add_index :line_items, :voucher_id
    add_index :line_items, :status
    add_index :line_items, :created_at
  end

  def self.down
    drop_table :line_items
  end
end
