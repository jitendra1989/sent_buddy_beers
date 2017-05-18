class AddNewBarFields < ActiveRecord::Migration
  def self.up
    add_column :bars, :url, :string
    add_column :bars, :customer_voucher_limit, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :bars, :url
    remove_column :bars, :customer_voucher_limit
  end
end
