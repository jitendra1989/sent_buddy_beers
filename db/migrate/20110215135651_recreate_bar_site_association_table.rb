class RecreateBarSiteAssociationTable < ActiveRecord::Migration
  def self.up
    drop_table :bars_sites

    create_table :bar_sites do |t|
      t.integer :bar_id
      t.integer :site_id

      t.timestamps
    end
  end

  def self.down
    drop_table :bar_sites

    create_table :bars_sites, :id => false do |t|
      t.integer :bar_id
      t.integer :site_id
    end
  end
end
