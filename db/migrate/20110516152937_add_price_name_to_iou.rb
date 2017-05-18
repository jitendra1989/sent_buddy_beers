class AddPriceNameToIou < ActiveRecord::Migration
  def self.up
    add_column :ious, :price_name, :string
    
    Iou.paid.each do |iou|
      iou.update_attribute(:price_name, iou.price.present? ? iou.price.name : [iou.try(:brand).try(:name), iou.try(:beer).try(:name)].join(" "))
    end
  end

  def self.down
    remove_column :ious, :price_name
  end
end
