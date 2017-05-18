class ChangeBarDescriptionToOldDescription < ActiveRecord::Migration
  def self.up
    rename_column :bars, :description, :old_description
  end

  def self.down
    rename_column :bars, :old_description, :description
  end
end
