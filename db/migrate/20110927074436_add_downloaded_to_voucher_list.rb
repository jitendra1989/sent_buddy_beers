class AddDownloadedToVoucherList < ActiveRecord::Migration
  def self.up
    if add_column(:voucher_lists, :downloaded, :boolean, :null => false, :default => true)
      change_column :voucher_lists, :downloaded, :boolean, :null => false, :default => false
    end
  end

  def self.down
    remove_column :voucher_lists, :downloaded
  end
end
