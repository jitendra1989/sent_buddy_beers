class CreatePaidVouchers < ActiveRecord::Migration
  def self.up
    create_table :paid_vouchers do |t|
      t.integer :voucher_id
      t.datetime :paid_at
      t.boolean :is_paid

      t.timestamps
    end
  end

  def self.down
    drop_table :paid_vouchers
  end
end
