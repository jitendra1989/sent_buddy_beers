class CreateBarsSites < ActiveRecord::Migration
  def self.up
    create_table :bars_sites, :id => false do |t|
      t.integer :bar_id
      t.integer :site_id
    end
  end

  def self.down
    drop_table :bars_sites
  end
end
