class AddCachedSlugsToBar < ActiveRecord::Migration
  def self.up
    add_column :bars, :cached_slug, :string
    add_index  :bars, :cached_slug, :unique => true
  end

  def self.down
    remove_column :bars, :cached_slug
  end
end
