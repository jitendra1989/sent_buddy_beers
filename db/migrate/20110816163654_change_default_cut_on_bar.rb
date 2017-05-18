class ChangeDefaultCutOnBar < ActiveRecord::Migration
  def self.up
    change_column :bars, :percent_cut, :integer, :default => 30
  end

  def self.down
    change_column :bars, :percent_cut, :integer, :default => 70
  end
end
