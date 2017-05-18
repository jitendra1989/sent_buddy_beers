class GroupDrink < ActiveRecord::Base
  include Discountable
  attr_accessor :recipient_phone_country_code
  
  has_many :vouchers
  has_one :facebook_request
  
  belongs_to :iou
  belongs_to :beverage
  belongs_to :price
  belongs_to :brand
  belongs_to :beer
  belongs_to :recipient, :class_name => "User"
  
  scope :expired, where(:expired => true)
  scope :find_set_drinks_with_created_at, lambda { |beginning_date, end_date| where("created_at >= ? AND created_at <= ? AND paid=?", beginning_date, end_date, true) }
  scope :received_drinks, lambda {|user_id| where(:recipient_id => user_id)}
  validates_presence_of :recipient_email, :unless => [:smsable?, :facebookable?]
  validates_format_of :recipient_email, :with => Devise.email_regexp, :message => 'should look like an email', :if => :emailable?
  validates_presence_of :recipient_phone, :unless => [:emailable?, :facebookable?]
  validates_numericality_of :recipient_phone, :if => :smsable?
  validates_length_of :recipient_phone, :minimum => 7, :if => :smsable?
  validates_presence_of :recipient_facebook_uid, :unless => [:emailable?, :smsable?]
  
  before_validation :check_for_existing_recipient, :update_missing_attributes, :strip_phone_number, :join_phone_numbers
  before_create :set_expiration_date
  
  
  def check_for_existing_recipient
    if recipient_facebook_uid.present?
      if fb_user = User.find_by_facebook_uid(recipient_facebook_uid)
        self.recipient = fb_user
      end
    end
    if recipient_email.present?
      emails = Email.with_email_like(self.recipient_email)
      if email = emails.present? ? emails.first : nil
        self.recipient = email.user if email.email.present? and email.user.active_for_authentication?
      end
    end
    unless recipient_phone.blank?
      self.recipient = User.active.find_by_phone_number(recipient_phone.to_s)
    end
    if recipient_id and user = User.find_by_id(recipient_id)
      if recipient_email.blank?
        self.recipient_email = user.emails.primary.present? ? user.emails.primary.first.email : user.emails.first.email
      end
    end
  end
  
  def update_missing_attributes
    if self.price
      write_attribute(:beer_id, self.price.beer_id) if price.beer_id
      write_attribute(:cents, self.price.cents.to_i * (self.quantity.to_i || 1).to_i)
      write_attribute(:discounted_cents, self.price.discounted_cents.to_i * (self.quantity.to_i || 1).to_i)
      write_attribute(:discounted, self.price.discounted)
      write_attribute(:currency, self.price.currency)
      write_attribute(:price_name, self.price.name)
      write_attribute(:beverage_name, self.price.beverage.name) if self.price.beverage
    end
    if self.beer.present?
      write_attribute(:beer_name, self.beer.name)
      write_attribute(:brand_id, self.beer.brand_id)
    end
    if recipient.present? and recipient.facebook_user?
      write_attribute(:recipient_facebook_uid, recipient.facebook_uid)
    end
    write_attribute(:brand_name, self.brand.name) if self.brand.present?
  end
  
  def send_sms_to_recipient(msg=sms_message)
    TwilioClient.new.send_message(phone_with_country_code, msg)
  end
  
  def sms_message
    msg = I18n.translate("sms.message", :name => iou.sender_name.capitalize, :recipient => recipient_name.capitalize)
    # TODO: Make this URL dynamic
    url = Rails.application.routes.url_helpers.app_download_url(:host => iou.site.domain)
    msg += " #{url}"
  end
  
  def track!
    Gabba::Gabba.new("UA-750037-13", "#{iou.site.subdomain ? iou.site.subdomain : "www"}.buddybeers.com").event("Vouchers", "Purchase", iou.bar.name, quantity)
    Gabba::Gabba.new("UA-750037-13", "#{iou.site.subdomain ? iou.site.subdomain : "www"}.buddybeers.com").event("Sales", "Ordered", price_name, total.exchange_to("USD").to_s)
  end
  
  def post_to_twitter!
    if iou.public? and Rails.env.production?
      sender_name_split = (iou.sender.to_s.split(" ").length > 1) ? [iou.sender_name.to_s.split(" ")[0], "#{iou.sender_name.to_s.split(" ")[1][0,1]}."].join(" ") : iou.sender.to_s
      if recipient_name.present?
        recipient_name_split = (recipient_name.split(" ").length > 1) ? [recipient_name.split(" ")[0], "#{recipient_name.split(" ")[1][0,1]}."].join(" ") : recipient_name
      else
        recipient_name_split = I18n.translate("global.generic_friend", :locale => sender.language.to_sym)
      end
      options = {}
      options.merge!(:lat => iou.bar.lat, :long => iou.bar.lng) if iou.bar.geocoded?
      Twitter.update(I18n.translate("ious.twitter.status", :sender => iou.sender_name_split, :recipient => recipient_name_split, :beer => [quantity, price_name].join(" "), :bar => iou.bar.name, :city => iou.bar.city.name, :memo => memo, :url => Rails.application.routes.url_helpers.bar_url(iou.bar, :host => iou.site ? iou.site.domain : Site.default.domain), :locale => iou.sender.language.to_sym), options)
    end
  rescue
    true
  end
  
  def strip_phone_number
    # This will strip all the weird characters the user enters and then to_i will delete any leading zeros
    unless recipient_phone.blank?
      self.recipient_phone = recipient_phone.to_s.gsub(/[^0-9]/, "").to_i
    end
  end
  
  def join_phone_numbers
    unless recipient_phone.to_s.starts_with?(recipient_phone_country_code) or recipient_phone.blank?
      self.recipient_phone = [recipient_phone_country_code, recipient_phone].join().to_i
    end
  end

  def smsable?
    recipient_phone.present?
  end
  
  def phone_with_country_code
    unless recipient_phone.to_s.include?("+")
      "+#{recipient_phone}"
    else
      recipient_phone
    end
  end
  
  def emailable?
    recipient_email.present? or (recipient.present? and recipient.email.present?)
  end
  
  def facebookable?
    recipient_facebook_uid.present? or (recipient.present? and recipient.facebook_uid?)
  end
  
  def set_status_to_valid
    self.status = "valid"
  end

  def set_expiration_date
    self.expires_at = 6.months.from_now.beginning_of_day
  end
  
  def price_in_bucks
    total.exchange_to("USD").cents #base currency is USD
  end
  
  def create_fb_app_requests
    FacebookRequest.create!(:iou => iou, :group_drink => self, :sender_id => iou.sender.facebook_uid, :recipient_id => recipient_facebook_uid) if recipient.present?
  end
  
  def calculate_amount
    price.total.to_f * quantity.to_i
  end
  
  def expire!
    unless redeemed? or expired?
      vouchers.redeemable.each do |voucher|
        # Promotional vouchers are not paid out because they are sent by the bar
        # Company_promotional vouchers are paid out because they are sent by Buddy Beers
        # We still create a line item for them for our records
        if promotional
          LineItem.create(:bar_id => iou.bar_id, :iou_id => iou.id, :voucher_id => voucher.id,
                          :payout_percent => 0, :status => "expired",
                          :cents => 0, :currency => voucher.currency)
        else
          LineItem.create(:bar_id => iou.bar_id, :iou_id => iou.id, :voucher_id => voucher.id,
                          :payout_percent => 100 - bar.percent_expired_cut, :status => "expired",
                          :cents => voucher.total.cents * (100 - iou.bar.percent_expired_cut) / 100.0, :currency => voucher.currency)
        end
      end
      self.update_attributes(:status => "expired", :expired => true)
    end
  end

  def expired?
    expired and status == "expired"
  end
  
  def paid?
    self.paid and (self.status == "valid")
  end

  def redeem!
    update_attribute(:status, 'redeemed') if vouchers.each(&:redeem!)
  end

  def redeemed?
    vouchers.all?(&:redeemed?)
  end
  
end


