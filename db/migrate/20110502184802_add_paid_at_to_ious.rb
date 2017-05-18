class AddPaidAtToIous < ActiveRecord::Migration
  def self.up
    add_column :ious, :paid_at, :datetime
  end

  def self.down
    remove_column :ious, :paid_at
  end
end
