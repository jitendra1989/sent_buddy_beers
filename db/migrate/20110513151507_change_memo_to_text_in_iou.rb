class ChangeMemoToTextInIou < ActiveRecord::Migration
  def self.up
    change_column :ious, :memo, :text
  end

  def self.down
    Iou.all.each do |iou|
      memo = iou.memo
      iou.update_attribute(:memo, memo.first(255)) if memo.present?
    end
    
    change_column :ious, :memo, :string
  end
end