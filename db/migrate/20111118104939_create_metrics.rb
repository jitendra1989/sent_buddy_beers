class CreateMetrics < ActiveRecord::Migration
  def self.up
    create_table :metrics do |t|
      t.string :name
      t.string :value
      t.integer :user_id
      t.datetime :achieved_at
      t.timestamps
    end
    
    add_index :metrics, :name
    add_index :metrics, :value
    add_index :metrics, :user_id
    add_index :metrics, :achieved_at
  end

  def self.down
    drop_table :metrics
  end
end
