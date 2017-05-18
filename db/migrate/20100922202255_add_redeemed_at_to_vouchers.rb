class AddRedeemedAtToVouchers < ActiveRecord::Migration
  def self.up
    add_column :vouchers, :redeemed_at, :datetime
  end

  def self.down
    remove_column :vouchers, :redeemed_at
  end
end
