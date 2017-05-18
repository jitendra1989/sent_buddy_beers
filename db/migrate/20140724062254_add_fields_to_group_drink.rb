class AddFieldsToGroupDrink < ActiveRecord::Migration
  def self.up
    add_column :group_drinks, :beer_id, :integer
    add_column :group_drinks, :cents, :integer
    add_column :group_drinks, :discounted_cents, :integer
    add_column :group_drinks, :discounted, :boolean
    add_column :group_drinks, :currency, :string, :default => "USD"
    add_column :group_drinks, :price_name, :string
    add_column :group_drinks, :beverage_name, :string
    add_column :group_drinks, :beer_name, :string
    add_column :group_drinks, :brand_id, :integer
    add_column :group_drinks, :recipient_facebook_uid, :integer
    add_column :group_drinks, :brand_name, :string
  end

  def self.down
    remove_column :group_drinks, :beer_id
    remove_column :group_drinks, :cents
    remove_column :group_drinks, :discounted_cents
    remove_column :group_drinks, :discounted
    remove_column :group_drinks, :currency
    remove_column :group_drinks, :price_name
    remove_column :group_drinks, :beverage_name
    remove_column :group_drinks, :beer_name
    remove_column :group_drinks, :brand_id
    remove_column :group_drinks, :recipient_facebook_uid
    remove_column :group_drinks, :brand_name
  end
end
