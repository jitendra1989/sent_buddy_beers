class CreateKarmaPoints < ActiveRecord::Migration
  def self.up
    create_table :karma_points do |t|
      t.integer :value
      t.integer :user_id
      t.integer :pointable_id
      t.string :pointable_type
      t.boolean :like, :default => false, :null => false

      t.timestamps
    end
    
    add_index :karma_points, [:pointable_type, :pointable_id]
  end

  def self.down
    drop_table :karma_points
  end
end
