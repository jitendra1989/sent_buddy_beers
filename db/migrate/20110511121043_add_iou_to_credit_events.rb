class AddIouToCreditEvents < ActiveRecord::Migration
  def self.up
    add_column :credit_events, :iou_id, :integer
    
    change_column :credit_events, :provider, :string, :default => "Ultimate Pay", :null => false
    
    add_index :credit_events, :iou_id
  end

  def self.down
    remove_column :credit_events, :iou_id
    
    change_column :credit_events, :provider, :string, :default => "Social Gold", :null => false
    
    remove_index :credit_events, :iou_id
  end
end
