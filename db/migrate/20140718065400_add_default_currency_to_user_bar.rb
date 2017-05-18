class AddDefaultCurrencyToUserBar < ActiveRecord::Migration
  def self.up
    change_column :users, :default_currency, :string, :null => false, :default => "USD"
    change_column :bars, :default_currency, :string, :limit => 3, :default => "USD"
  end

  def self.down
    change_column :users, :default_currency, :string, :null => false, :default => "EUR"
    change_column :bars, :default_currency, :string, :limit => 3, :default => "EUR"
  end
end
