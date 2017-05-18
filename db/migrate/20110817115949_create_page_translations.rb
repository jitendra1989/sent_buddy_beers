class CreatePageTranslations < ActiveRecord::Migration
  def self.up 
    create_table(:page_translations) do |t|
      t.references :page
      t.string :locale

      t.string :title
      t.text :body
      t.string :slug

      t.timestamps
    end
    add_index :page_translations, [:page_id, :locale, :slug], :unique => true
  end

  def self.down
    drop_table :page_translations
  end
end

