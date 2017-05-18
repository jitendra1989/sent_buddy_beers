class AddRedeemedVoucherNotificationTimeframeToBars < ActiveRecord::Migration
  def self.up
    add_column :bars, :redeemed_voucher_notification_timeframe, :string, :null => false, :default => "weekly"
    add_index :bars, :redeemed_voucher_notification_timeframe
  end

  def self.down
    remove_column :bars, :redeemed_voucher_notification_timeframe
  end
end
