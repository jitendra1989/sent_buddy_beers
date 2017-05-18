class CreateSubcriptions < ActiveRecord::Migration
  def self.up
    create_table :subcriptions do |t|
      t.integer :payer_id
      t.string :payer_name
      t.string :paypal_payer_id
      t.string :paypal_token
      t.string :quantity
      t.float :amount
      t.string :currency
      t.string :iou_id

      t.timestamps
    end
  end

  def self.down
    drop_table :subcriptions
  end
end
