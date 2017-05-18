class CreateBuddyUps < ActiveRecord::Migration
  def self.up
    create_table :buddy_ups do |t|
      t.string :person_name
      t.string :place_name
      t.string :thing_name
      t.text :reason
      t.string :facebook_id
      t.integer :comments_count
      t.integer :likes_count
      t.integer :user_id

      t.timestamps
    end
    
    add_index :buddy_ups, :facebook_id
    add_index :buddy_ups, :user_id
  end

  def self.down
    drop_table :buddy_ups
  end
end
