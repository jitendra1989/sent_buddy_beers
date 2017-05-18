class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :title
      t.string :event_type
      t.datetime :day_of_the_event
      t.integer :user_id
      t.string :friend_fb_id

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
