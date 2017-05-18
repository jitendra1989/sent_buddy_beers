class AddPriceToIou < ActiveRecord::Migration
  def self.up
    add_column :ious, :price_id, :integer
    
    add_index :ious, :price_id
    
    Iou.all.each do |iou|
      @price = Price.find_by_beer_id_and_bar_id(iou.beer_id, iou.bar_id)
      if @price.present?
        iou.price = @price
        iou.save
      end
    end
  end

  def self.down
    remove_column :ious, :price_id
  end
end
