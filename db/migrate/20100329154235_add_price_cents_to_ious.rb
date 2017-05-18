class AddPriceCentsToIous < ActiveRecord::Migration
  def self.up
    add_column :ious, :price_cents, :integer, :default => 0
    
    Iou.all.each do |iou|
      next if iou.beer.blank? or iou.bar.blank? 
      iou.update_attribute(:price_cents, Price.find_by_beer_id_and_bar_id(iou.beer.id, iou.bar.id).cents * iou.quantity)
    end
  end

  def self.down
    remove_column :ious, :price_cents
  end
end
