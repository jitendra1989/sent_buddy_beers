class AddSlugThToBars < ActiveRecord::Migration
  def self.up
    add_column :bars, :slug_th, :string, :unique => true
    add_index :bars, :slug_th
    I18n.with_locale(:th) { Bar.all.each { |b| b.save } }
  end

  def self.down
    remove_column :bars, :slug_th
  end
end
