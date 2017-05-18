class Price < ActiveRecord::Base
  include Discountable

  belongs_to :beer
  belongs_to :bar
  belongs_to :beverage
  belongs_to :drink_type

  has_many :ious
  has_many :group_drinks

  validates_presence_of :name, :cents

  validates_presence_of :bar_id, :unless => Proc.new { |p| p.bar && p.bar.new_record? }
  
  default_scope :order => 'name ASC'
  scope :discounted, where(:discounted => true)
  scope :descending, order("discounted DESC, discounted_cents DESC, cents DESC")
  scope :ascending, order("discounted_cents ASC, cents ASC")
  
  if Rails.env.production? or Rails.env.staging?
    has_attached_file :photo, :storage => :s3,
                      :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
                      :path => "/:style/:filename",
                      :styles => { :square => "320x320#", :iphone_retina => "110x110>", :iphone => "55x55>", :small => "60x60>", :thumb => "50x50#" }
  else
    has_attached_file :photo,
                      :url => "/assets/prices/:id/:style/:basename.:extension",
                      :path => ":rails_root/public/assets/prices/:id/:style/:basename.:extension",
                      :styles => { :square => "320x320#", :iphone_retina => "110x110>", :iphone => "55x55>", :small => "60x60>", :thumb => "50x50#" }
  end

  before_save do |price|
    price.beverage = Beverage.default if price.beverage.nil?
  end

  after_save do |price|
    VoucherList.find_or_create_by_price(price)
    price.prune(price.cents_was, price.currency_was) if price.changed? 
  end

  after_destroy do |price|
    price.prune
  end

  def prune(cents = nil, currency = nil)
    cents ||= self.cents
    currency ||= self.currency

    bar.vouchers.available.scoped(:conditions => {:cents => cents, :currency => currency}).destroy_all unless bar.reload.tiers.include?([cents, currency])
    VoucherList.find_all_by_bar_id_and_cents_and_currency_and_archived_and_closed(bar.id, cents, currency, false, false).each(&:save)
  end
  
  def details
    [drink_type, volume].compact.reject(&:blank?).join(", ")
  end
  
end
