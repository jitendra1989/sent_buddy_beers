class RemoveVirtualFromIous < ActiveRecord::Migration
  def self.up
    Iou.find_all_by_virtual(true).each do |iou|
      iou.destroy()
    end
    
    remove_column :ious, :virtual
  end

  def self.down
    add_column :ious, :virtual, :boolean, :default => false, :null => false
  end
end
