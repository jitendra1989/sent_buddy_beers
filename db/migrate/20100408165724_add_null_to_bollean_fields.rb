class AddNullToBolleanFields < ActiveRecord::Migration
  def self.up
    change_column :ious, :virtual, :boolean, :null => false
  end

  def self.down
    change_column :ious, :virtual, :boolean, :null => true
  end
end
