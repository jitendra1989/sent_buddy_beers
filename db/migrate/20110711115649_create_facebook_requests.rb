class CreateFacebookRequests < ActiveRecord::Migration
  def self.up
    create_table :facebook_requests do |t|
      t.integer :sender_id, :limit => 8
      t.integer :recipient_id, :limit => 8
      t.integer :iou_id, :limit => 8
      t.integer :facebook_ref_id, :limit => 8
      t.boolean :open, :null => false, :default => true
      t.timestamps
    end
    
    add_index :facebook_requests, :sender_id
    add_index :facebook_requests, :recipient_id
    add_index :facebook_requests, :iou_id
    add_index :facebook_requests, :facebook_ref_id
  end

  def self.down
    remove_index :facebook_requests, :sender_id
    remove_index :facebook_requests, :recipient_id
    remove_index :facebook_requests, :iou_id
    remove_index :facebook_requests, :facebook_ref_id
    drop_table :facebook_requests
  end
end
