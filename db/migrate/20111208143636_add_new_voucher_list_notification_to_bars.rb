class AddNewVoucherListNotificationToBars < ActiveRecord::Migration
  def self.up
    add_column :bars, :new_voucher_list_notification, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :bars, :new_voucher_list_notification
  end
end
