class AddDefaultCurrencyToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :default_currency, :string, :null => false, :default => "EUR"
  end

  def self.down
    remove_column :users, :default_currency
  end
end
