class CreateBarTranslations < ActiveRecord::Migration
  def self.up 
    create_table(:bar_translations) do |t|
      t.references :bar
      t.string :locale

      t.text :description

      t.timestamps
    end
    add_index :bar_translations, [:bar_id, :locale], :unique => true
  end

  def self.down
    drop_table :bar_translations
  end
end

