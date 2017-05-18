class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.text :text
      t.string :facebook_id
      t.integer :buddy_up_id
      t.integer :likes_count
      t.integer :user_id
      t.string :user_name
      t.string :user_facebook_id

      t.timestamps
    end
    
    add_index :comments, :facebook_id
    add_index :comments, :buddy_up_id
    add_index :comments, :user_id
    add_index :comments, :user_facebook_id
  end

  def self.down
    drop_table :comments
  end
end
