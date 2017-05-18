class CreatePaidVoucherDetails < ActiveRecord::Migration
  def self.up
    create_table :paid_voucher_details do |t|
      t.integer :no_of_redeemed_vouchers
      t.integer :affiliate_id
      t.datetime :date
      t.string :mode
      t.string :amount

      t.timestamps
    end
  end

  def self.down
    drop_table :paid_voucher_details
  end
end
