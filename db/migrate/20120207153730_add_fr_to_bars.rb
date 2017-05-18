class AddFrToBars < ActiveRecord::Migration
  def self.up
    add_column :bars, :slug_fr, :string, :unique => true
    add_index :bars, :slug_fr
    I18n.with_locale(:fr) { Bar.all.each { |b| b.save } }
  end

  def self.down
    remove_column :bars, :slug_fr
  end
end

