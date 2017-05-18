class CreateBuddyGroups < ActiveRecord::Migration
  def self.up
    create_table :buddy_groups do |t|
      t.string :name
      t.references :groupable, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :buddy_groups
  end
end
