class PageTranslation < ActiveRecord::Base
  puret_for :page
  
  extend FriendlyId
  friendly_id :transliterated_title, :use => :scoped, :scope => :page
  
  def transliterated_title
    ActiveSupport::Inflector.transliterate(title)
  end
end
