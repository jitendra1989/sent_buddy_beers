class AddCodeNameToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :code_name, :string
    Site.reset_column_information
    Site.update_all({:code_name => 'buddybeers', :name => 'BuddyBeers'})
  end

  def self.down
    remove_column :sites, :code_name
  end
end
