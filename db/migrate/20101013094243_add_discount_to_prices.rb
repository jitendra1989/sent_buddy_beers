class AddDiscountToPrices < ActiveRecord::Migration
  def self.up
    add_column :prices, :discounted_cents, :integer, :default => 0, :null => false
    add_column :prices, :discounted, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :prices, :discounted_cents
    remove_column :prices, :discounted
  end
end
