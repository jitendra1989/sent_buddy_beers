class AddAdditionalIouAttributes < ActiveRecord::Migration
  def self.up
    add_column :ious, :brand_name, :string
    add_column :ious, :beer_name, :string
    add_column :ious, :bar_name, :string
    add_column :ious, :beverage_name, :string
    
    Iou.all.each do |iou|
      iou.brand_name = iou.brand.name if iou.brand
      iou.beer_name = iou.beer.name if iou.beer
      iou.bar_name = iou.bar.name if iou.bar
      iou.beverage_name = iou.beverage.name if iou.beverage
      iou.save(false)
    end
  end

  def self.down
    remove_column :ious, :brand_name
    remove_column :ious, :beer_name
    remove_column :ious, :bar_name
    remove_column :ious, :beverage_name
  end
end
