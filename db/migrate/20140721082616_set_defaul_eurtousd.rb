class SetDefaulEurtousd < ActiveRecord::Migration
  def self.up
    change_column :prices, :currency, :string, :default => "USD"
    change_column :vouchers, :currency, :string, :null => false, :default => "USD"
    change_column :voucher_lists, :currency, :string, :null => false, :default => "USD"
    change_column :payout_models, :currency, :string, :null => false, :default => "USD"
    change_column :ious, :currency, :string, :null => false, :default => "USD"
  end

  def self.down
    change_column :prices, :currency, :string, :default => "EUR"
    change_column :vouchers, :currency, :string, :null => false, :default => "EUR"
    change_column :voucher_lists, :currency, :string, :null => false, :default => "EUR"
    change_column :payout_models, :currency, :string, :null => false, :default => "EUR"
    change_column :ious, :currency, :string, :null => false, :default => "EUR"
  end
end
