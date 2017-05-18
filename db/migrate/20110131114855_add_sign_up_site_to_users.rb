class AddSignUpSiteToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :sign_up_site_id, :integer
    add_index :users, :sign_up_site_id
  end

  def self.down
    remove_column :users, :sign_up_site_id
  end
end
