class ExpireAllExistingIous < ActiveRecord::Migration
  def self.up
    add_column :ious, :expired, :boolean, :default => false
    Iou.outstanding.each{ |iou| iou.expire! }
    Delayed::Job.enqueue ExpireIouJob.new, 0, Date.tomorrow.beginning_of_day
  end

  def self.down
    remove_column :ious, :expired
  end
end
