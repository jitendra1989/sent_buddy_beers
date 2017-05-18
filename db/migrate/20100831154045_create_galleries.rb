class CreateGalleries < ActiveRecord::Migration
  def self.up
    create_table :galleries do |t|
      t.integer :attachable_id
      t.string :attachable_type

      t.timestamps
    end
    
    add_index :galleries, :attachable_id
    add_index :galleries, :attachable_type
    
    Bar.all.each{|bar| bar.create_gallery!}
  end

  def self.down
    drop_table :galleries
  end
end
