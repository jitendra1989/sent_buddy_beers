class CreateEmployments < ActiveRecord::Migration
  def self.up
    create_table :employments do |t|
      t.integer :user_id, :null => false
      t.integer :bar_id, :null => false
      t.boolean :active, :null => false, :default => false
      t.timestamps
    end
    
    add_index :employments, :user_id
    add_index :employments, :bar_id
  end

  def self.down
    drop_table :employments
  end
end
