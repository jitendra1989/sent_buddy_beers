class Page < ActiveRecord::Base
  puret :title, :body, :slug
  
  acts_as_tree :order => :position
  
  has_and_belongs_to_many :sites
  
  validates_presence_of :title
  validates_presence_of :body
  validates_numericality_of :position
  
  default_scope order('position')
  #scope :roots, where(:parent_id => nil)
  scope :live, where(:published => true)
  scope :for_footer, where(:footer => true)
  scope :for_site_ids, lambda { |ids| select("DISTINCT(pages.*)").joins(:sites).where(:sites => { :id => ids }).readonly(false) }
  scope :for_site, lambda { |site| for_site_ids(site.id) }  
  scope :like, lambda { |query| joins(:translations).where("UPPER(page_translations.title) like ?", "%#{query.upcase}%") }
  
  #has_friendly_id :title, :use_slug => true, :approximate_ascii => true, :ascii_approximation_options => :german, :reserved_words => ["new", "edit", "delete", "destroy", "show", "index", "confirm", "submit"]
  
end
