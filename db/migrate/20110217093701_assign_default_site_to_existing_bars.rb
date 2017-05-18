class AssignDefaultSiteToExistingBars < ActiveRecord::Migration
  def self.up
    Bar.find_each(&:save)
  end

  def self.down
  end
end
