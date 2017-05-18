class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.boolean :navigation, :default => false, :null => false
      t.boolean :published, :default => false, :null => false
      t.boolean :footer, :default => false, :null => false

      t.timestamps
    end
    
    add_index :pages, :navigation
    add_index :pages, :published
    add_index :pages, :footer
  end

  def self.down
    drop_table :pages
  end
end
