class MigrateOldDescriptionsToPuret < ActiveRecord::Migration
  def self.up
    [:en, :de].each do |locale|
      I18n.locale = locale
      Bar.find_each do |bar|
        bar.description = bar.old_description
        bar.save(false)
      end
    end
  end

  def self.down
    Bar.find_each do |bar|
      bar.old_description = bar.description
      bar.save(false)
    end
  end
end
