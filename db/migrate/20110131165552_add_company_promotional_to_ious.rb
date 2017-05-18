class AddCompanyPromotionalToIous < ActiveRecord::Migration
  def self.up
    add_column :ious, :company_promotional, :boolean, :default => false, :null => false
    
    Iou.promotional.each do |iou|
      iou.promotional = false
      iou.company_promotional = true
      iou.save(:validate => false)
    end
  end

  def self.down
    Iou.company_promotional.each do |iou|
      iou.promotional = true
      iou.company_promotional = false
      iou.save(:validate => false)
    end
    
    remove_column :ious, :company_promotional
  end
end
