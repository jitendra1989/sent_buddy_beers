# -*- coding: utf-8 -*-
class Bar < ActiveRecord::Base
  require 'iconv'

  puret :description

  acts_as_mappable :default_units => :kms

  cattr_reader :per_page
  @@per_page = 10
  CLOSING_TIME = OPENING_TIME = ['12:00AM', '12:30AM', '01:00AM', '01:30AM', '02:00AM', '02:30AM', '03:00AM', '03:30AM', '04:00AM', '04:30AM', '05:00AM', '05:30AM', '06:00AM', '06:30AM', '07:00AM', '07:30AM', '08:00AM', '08:30AM', '09:00AM', '09:30AM', '10:00AM', '10:30AM', '11:00AM', '11:30AM', '12:00PM', '12:30PM', '01:00PM', '01:30PM', '02:00PM', '02:30PM', '03:00PM', '03:30PM', '04:00PM', '04:30PM', '05:00PM', '05:30PM', '06:00PM', '06:30PM', '07:00PM', '07:30PM', '08:00PM', '08:30PM', '09:00PM', '09:30PM', '10:00PM', '10:30PM', '11:00PM', '11:30PM']

  belongs_to :affiliate
  belongs_to :country
  belongs_to :city
  belongs_to :bro
  has_many :employments, :dependent => :destroy
  has_many :employees, :through => :employments, :source => :user

  has_one :gallery, :as => :attachable
  has_many :ious, :dependent => :destroy, :order => 'updated_at ASC'
  has_many :prices, :dependent => :destroy, :before_add => :set_nest
  has_many :beers, :through => :prices
  has_many :vouchers, :dependent => :destroy
  has_many :voucher_lists, :dependent => :destroy
  has_many :line_items
  has_many :payout_models, :dependent => :destroy, :order => 'low_cents ASC'
  has_many :bar_sites
  has_many :sites, :through => :bar_sites
  paperclip_opts = {
    :styles => { :full => "690x460", :standard => "270x115#", :square => "100x100#", :thumb => "50x50#" }
  }

  unless Rails.env.development?
    paperclip_opts.merge! :storage        => :s3,
                          :s3_credentials => "#{Rails.root}/config/s3.yml",
                          :path => "/:style/:filename"
  end

  has_attached_file :logo, paperclip_opts

  validates_presence_of :name, :address, :country_id, :city_id, :percent_cut, :percent_expired_cut, :customer_voucher_limit
  validates_presence_of :contact_email, :contact_phone_number, :contact_name, :if => :inactive?
  validates_format_of :contact_email, :with => Devise.email_regexp, :message => I18n.t("activerecord.errors.messages.look_like_email"), :if => :inactive?
  validates_numericality_of :percent_cut, :percent_expired_cut
  # validate :require_one_price, :unless => :inactive? # causing loads of issues at the moment. especially in test env. -tjt

  # Need to add validations for when Geokit returns multiple locations for an address lookup

  before_validation :remove_leading_and_trailing_spaces
  before_create :generate_token
  before_save :geocode, :prepend_http_in_url_if_needed, :strip_twitter_url_from_handle, :associate_with_default_site, :strip_whitespace

  after_create :create_gallery!, :create_standard_payout_model!

  scope :geocoded, where('bars.lat IS NOT NULL AND bars.lng IS NOT NULL')
  scope :active, where(:active => true)
  scope :inactive, where(:active => false, :pending => false)
  scope :pending, where(:pending => true)
  scope :for_site_ids, lambda { |ids| select("DISTINCT(bars.*)").joins(:sites).where(:sites => { :id => ids }).readonly(false) }
  scope :for_site, lambda { |site| for_site_ids(site.id) }
  scope :for_site_admin, lambda { |site_admin| for_site_ids(site_admin.site_ids) }
  scope :like, lambda {|query| where("UPPER(name) like ?", "%#{query.upcase}%") }
  scope :alphabetically_by_country_and_city, includes(:country).includes(:city).order("countries.name ASC, cities.name ASC, bars.name ASC")
  scope :find_venue_with_created_at, lambda { |beginning_date, end_date| where("created_at >= ? AND created_at <= ?", beginning_date, end_date) }

  accepts_nested_attributes_for :vouchers
  accepts_nested_attributes_for :payout_models
  accepts_nested_attributes_for :prices, :allow_destroy => true, :reject_if => proc { |attrs| attrs['name'].blank? }

  # badass URLs courtesy of http://github.com/norman/friendly_id
  # more info: http://norman.github.com/friendly_id/file.Guide.html#setup
  # has_friendly_id :name_city_and_country, :use_slug => true, :approximate_ascii => true, :ascii_approximation_options => :german, :reserved_words => ["confirm", "submit"]
  extend FriendlyId
  friendly_id :name_city_and_country, :use => :i18n #:use => :slugged, :slug_column => :cached_slug, :reserved_words => ["confirm", "submit"]

  def self.get_venues
    @venues = @venues || Bar.all
  end

  def name_city_and_country
    ActiveSupport::Inflector.transliterate("#{name} #{city.try(:name)} #{I18n.t("countries.#{country.printable_name.parameterize("_")}") if country}")
  end

  def notification_timelines
    ["never", "daily", "weekly", "monthly"]
  end

  # Can I move this to an association?
  def brands
    beers.collect{ |b| b.brand }
  end

  def full_address
    [address, city.try(:name), I18n.t("countries.#{country.printable_name.parameterize.gsub("-", "_")}")].join(", ")
  end

  def full_address_except_country
    [address, city.name].join(", ")
  end

  def bar_countries
    I18n.t("countries.#{country.printable_name.parameterize.gsub("-", "_")}")
  end

  def geocode
    I18n.with_locale(:en) do
      ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
      valid_string = ic.iconv(full_address + ' ')[0..-2]
      coords = GeoKit::Geocoders::MultiGeocoder.geocode(valid_string)
      #country = Country.find_by_iso(coords.country_code)
      #self.lat, self.lng, self.city, self.country = coords.lat, coords.lng, coords.city, (country ? country.id : nil) if coords.success and coords.all.size == 1
      self.lat, self.lng = coords.lat, coords.lng if coords.success and coords.all.size == 1
    end
  end

  def geocoded?
    self.lat.present? and self.lng.present?
  end

  def inactive?
    !active
  end

  def generate_token
    write_attribute(:token, String.tokenize(4).upcase)
  end

  def drinks_sold
    ious.paid.inject(0){|sum, iou| sum += iou.quantity}
  end

  def drinks_redeemed
    line_items.redeemed.size#inject(0){|sum, iou| sum += iou.quantity}
  end

  def profit(from = nil, to = nil)
    from = Time.now.beginning_of_month if from.nil?
    to = from.end_of_month if to.nil?

    # profit = Money.new(vouchers.redeemed.all(:conditions => ["redeemed_at BETWEEN ? AND ?", from, to]).sum(&:cents) * (100 - percent_cut) / 100.0)
    # profit += Money.new(vouchers.expired.all(:conditions => ["ious.expires_at BETWEEN ? AND ?", from, to], :include => :iou).sum(&:cents) * (100 - percent_expired_cut) / 100.0)
    bar_profit = line_items.all(:conditions => ["created_at BETWEEN ? AND ?", from, to]).sum(&:amount)
    bar_profit = Money.new(0, default_currency) if (bar_profit.is_a?(Fixnum) and bar_profit == 0)
    return bar_profit
  end

  def turnover(from = nil, to = nil)
    from = Time.now.beginning_of_month if from.nil?
    to = from.end_of_month if to.nil?
    sum = ious.paid.outstanding.all(:conditions => ["created_at BETWEEN ? AND ?", from, to]).sum(&:total)
    "#{(sum * (100 - percent_expired_cut) / 100.0)} – #{(sum * (100 - percent_cut) / 100.0)}"
  end

  def tiers
    prices.map { |p| [p.cents, p.currency] }.uniq
  end

  def create_delete_job
    # This delayed job deletes a bar in 8 hours if it is still pending. This should allow enough time for the bar owner to finish their application.
    Delayed::Job.enqueue DeletePendingBarJob.new(self.id), {:priority => 0, :run_at => 8.hours.from_now}
  end

  def submit!
    self.update_attribute(:pending, false)
    Notifier.new_bar_signup(self).deliver
  end

  def create_gallery!
    Gallery.create(:attachable => self) unless self.gallery.present?
  end

  def create_standard_payout_model!
    PayoutModel.create(:bar => self, :percent_payout => (100 - percent_cut), :currency => default_currency)
  end

  def send_redeemed_voucher_report!
    unless (redeemed_voucher_notification_timeframe == "never") or inactive?
      case redeemed_voucher_notification_timeframe
      when "daily"
        redeemed_vouchers = vouchers.redeemed.where(:redeemed_at => (1.day.ago.beginning_of_day)..(1.day.ago.end_of_day))
      when "weekly"
        redeemed_vouchers = vouchers.redeemed.where(:redeemed_at => (1.week.ago.beginning_of_day)..(1.week.ago.end_of_day))
      when "monthly"
        redeemed_vouchers = vouchers.redeemed.where(:redeemed_at => (1.month.ago.beginning_of_day)..(1.month.ago.end_of_day))
      end
      if redeemed_vouchers.present?
        Notifier.redeemed_voucher_report(self, redeemed_voucher_notification_timeframe, redeemed_vouchers).deliver
      end
    end
  end

  # Used to see if user has permission to redeem the voucher
  def employs?(user)
    employees.include?(user) or (affiliate == user) or user.admin?
  end

  def fb_image_url
    if logo.file?
      URI.encode(logo(:thumb))
    elsif (gallery and gallery.photos.present?)
      if gallery.photos.first.photo.file?
        URI.encode(gallery.photos.first.photo(:thumb))
      else
        "http://#{Site.default.domain}/images/sites/buddybeers/avatars/tiny/missing.png"
      end
    else
      "http://#{Site.default.domain}/images/sites/buddybeers/avatars/tiny/missing.png"
    end
  end

  def slug
    friendly_id
  end

  private

  def associate_with_default_site
    self.sites << Site.default unless sites.include?(Site.default)
  end

  def prepend_http_in_url_if_needed
    self.url = "http://#{self.url}" unless self.url.blank? || self.url.starts_with?('http://')
  end

  def strip_twitter_url_from_handle
    self.twitter_handle = self.twitter_handle.gsub("http://", "").gsub("twitter.com/", "").gsub("www.", "") unless self.twitter_handle.blank?
  end

  def strip_whitespace
    self.name = self.name.strip
  end

  def set_nest(price)
    price.bar ||= self
  end

  def require_one_price
    errors.add(:base, "You must provide at least one price") if prices.blank?
  end

  def remove_leading_and_trailing_spaces
    self.contact_email.strip! if self.contact_email.is_a?(String)
  end
end
