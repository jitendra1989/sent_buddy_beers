class AddItToBars < ActiveRecord::Migration
  def self.up
    add_column :bars, :slug_it, :string, :unique => true
    add_index :bars, :slug_it
    I18n.with_locale(:it) { Bar.all.each { |b| b.save } }
  end

  def self.down
    remove_column :bars, :slug_it
  end
end
