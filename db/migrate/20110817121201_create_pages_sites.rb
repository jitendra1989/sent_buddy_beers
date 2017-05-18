class CreatePagesSites < ActiveRecord::Migration
  def self.up
    create_table :pages_sites, :id => false do |t|
      t.integer :page_id
      t.integer :site_id
    end
    
    add_index :pages_sites, :page_id
    add_index :pages_sites, :site_id
  end

  def self.down
    drop_table :pages_sites
  end
end
