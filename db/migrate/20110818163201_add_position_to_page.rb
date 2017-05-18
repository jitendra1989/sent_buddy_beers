class AddPositionToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :position, :integer, :default => 0
    add_index :pages, :position
  end

  def self.down
    remove_index :pages, :position
    remove_column :pages, :position
  end
end
