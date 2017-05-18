class AddCurrencyAndDiscountsToIouAndVouchers < ActiveRecord::Migration
  def self.up
    add_column :ious, :currency, :string, :null => false, :default => "EUR"
    add_column :ious, :discounted_cents, :integer, :default => 0, :null => false
    add_column :ious, :discounted, :boolean, :default => false, :null => false
    add_column :vouchers, :discounted_cents, :integer, :default => 0, :null => false
    add_column :vouchers, :discounted, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :ious, :currency
    remove_column :ious, :discounted_cents
    remove_column :ious, :discounted
    remove_column :vouchers, :discounted_cents
    remove_column :vouchers, :discounted
  end
end
