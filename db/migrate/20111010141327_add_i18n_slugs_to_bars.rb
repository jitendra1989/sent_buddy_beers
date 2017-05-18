class AddI18nSlugsToBars < ActiveRecord::Migration
  def self.up
    add_column :bars, :slug_de, :string, :unique => true
    add_column :bars, :slug_en, :string, :unique => true
    add_column :bars, :slug_nl, :string, :unique => true
    
    add_index :bars, :slug_de
    add_index :bars, :slug_en
    add_index :bars, :slug_nl
    
    I18n.with_locale(:en) { Bar.all.each { |b| b.save } }
    I18n.with_locale(:de) { Bar.all.each { |b| b.save } }
    I18n.with_locale(:nl) { Bar.all.each { |b| b.save } }
  end

  def self.down
    remove_column :bars, :slug_de
    remove_column :bars, :slug_en
    remove_column :bars, :slug_nl
    
    # remove_index :bars, :slug_de
    # remove_index :bars, :slug_en
    # remove_index :bars, :slug_nl
  end
end
