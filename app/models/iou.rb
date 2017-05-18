class Iou < ActiveRecord::Base
  include Discountable

  attr_accessor :recipient_phone_country_code

  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
  belongs_to :beverage
  belongs_to :brand
  belongs_to :beer
  belongs_to :bar
  belongs_to :price
  belongs_to :site

  has_many :vouchers
  has_many :line_items
  has_many :group_drinks, :dependent => :destroy
  
  has_one :facebook_request
  has_one :credit_event
  accepts_nested_attributes_for :group_drinks, :allow_destroy => true, :reject_if => proc { |attrs| attrs['recipient_name'].blank? && (attrs['recipient_email'].blank? || attrs['recipient_phone'].blank?)  }

  validates_presence_of :status, :sender_id, :site 
  validates_presence_of :sender_name, :memo
  validates_inclusion_of :notified, :paid, :in => [true, false]
  validates :token, :presence => true, :uniqueness => true
  
  before_validation :update_missing_attributes, :generate_token
  before_create :set_expiration_date
  validate :validate_group_drinks
  
  scope :outstanding, where(:status => "valid")
  scope :completed, where(:status => ["valid", "redeemed", "expired"])
  scope :redeemed, where(:status => "redeemed")
  scope :paid, where(:paid => true)
  scope :public, where(:public => true)
  scope :promotional, where(:promotional => true)
  scope :company_promotional, where(:company_promotional => true)
  scope :expired, where(:expired => true)
  scope :expired_since, lambda { |date| expired.where(:status => "expired").where("expires_at >= ?", date) }
  scope :recent, where(:promotional => false).where(:company_promotional => false).where(:paid => true).order("created_at DESC")
  scope :for_site_ids, lambda { |ids| select("DISTINCT(ious.*)").joins(:bar => :sites).where(:sites => { :id => ids }) }
  scope :for_site_admin, lambda { |site_admin| for_site_ids(site_admin.site_ids) }
  scope :with_unique_sender, select("DISTINCT ON (ious.sender_id) ious.*").order("ious.sender_id, ious.created_at")

  # Callbacks...

  def update_missing_attributes
    write_attribute(:sender_name, self.sender.to_s) unless self.sender_name.present?
    write_attribute(:bar_name, self.bar.name) if self.bar.present?
    write_attribute(:beverage_name, self.beverage.name) if self.beverage.present?
  end

  def generate_token
    until token.present? and Iou.find_by_token(token).nil?
      self.token = String.tokenize(6)
    end
  end

  def set_status_to_valid
    self.status = "valid"
  end

  def set_expiration_date
    self.expires_at = 6.months.from_now.beginning_of_day
  end

  def date
    self.created_at.to_date
  end
  
  def total_cents
    group_drinks.map{ |gd| (gd.price.cents.to_f)*(gd.quantity.to_f)}.sum unless group_drinks.blank?
  end

  def total_quantity
    group_drinks.map(&:quantity).sum unless group_drinks.blank?
  end
  
  def item_name_list
    group_drinks.map{|gd| gd.price_name}
  end
  
  def calculate_total
    group_drinks.map{ |gd| gd.calculate_amount }.sum
  end

  # Methods and actions...

  def set_reminders!
    Delayed::Job.enqueue VoucherReminderJob.new(id), {:priority => 0, :run_at => (expires_at - 3.months).beginning_of_day}
    Delayed::Job.enqueue VoucherReminderJob.new(id), {:priority => 0, :run_at => (expires_at - 2.weeks).beginning_of_day}
  end

  def schedule_expiration!
    set_reminders!
    Delayed::Job.enqueue ExpireIouJob.new(self.id), {:priority => 0, :run_at => 6.months.from_now.beginning_of_day}
  end

  def send_notification!
    group_drinks.each do |group_drink| 
      transaction do
        # Send Email
        Notifier.voucher_notification(group_drink).deliver if group_drink.emailable?
        # Send SMS
        send_sms! if smsable?
        puts "=================================Sms Sending==========================="
        group_drink.send_sms_to_recipient if group_drink.smsable?
        
        group_drink.update_attribute(:notified, true)
      end
    end
  end
  
  def sms_message
    msg = I18n.translate("sms.message", :name => sender_name)
    # TODO: Make this URL dynamic
    url = Rails.application.routes.url_helpers.app_download_url(:host => site.domain)
    msg += " #{url}"
  end
  
  def send_sms!(msg=sms_message)
    request_params = {
        :token => TROPO_SMS_TOKEN,
        :msg => msg,
        'numberToDial' => recipient_phone,
        :iou_id => id
      }
    #logger.debug(request_params)
    #response = HTTParty.post("https://api.tropo.com/1.0/sessions", :body => request_params)
    response = HTTParty.post("https://api.tropo.com/1.0/sessions?action=create&", :body => request_params)
  end
  
  def sms_sent!
    update_attribute(:sms_notified_at, DateTime.now())
  rescue ActiveRecord::StaleObjectError
    sms_notified_at.present?
  end
  
  def post_to_twitter!
    if public? and Rails.env.production?
      sender_name_split = (sender.to_s.split(" ").length > 1) ? [sender_name.to_s.split(" ")[0], "#{sender_name.to_s.split(" ")[1][0,1]}."].join(" ") : sender.to_s
      if recipient_name.present?
        recipient_name_split = (recipient_name.split(" ").length > 1) ? [recipient_name.split(" ")[0], "#{recipient_name.split(" ")[1][0,1]}."].join(" ") : recipient_name
      else
        recipient_name_split = I18n.translate("global.generic_friend", :locale => sender.language.to_sym)
      end
      options = {}
      options.merge!(:lat => bar.lat, :long => bar.lng) if bar.geocoded?
      Twitter.update(I18n.translate("ious.twitter.status", :sender => sender_name_split, :recipient => recipient_name_split, :beer => [quantity, price_name].join(" "), :bar => bar.name, :city => bar.city.name, :memo => memo, :url => Rails.application.routes.url_helpers.bar_url(bar, :host => site ? site.domain : Site.default.domain), :locale => sender.language.to_sym), options)
    end
  rescue
    true
  end
  
  def track!
    Gabba::Gabba.new("UA-750037-13", "#{site.subdomain ? site.subdomain : "www"}.buddybeers.com").event("Vouchers", "Purchase", bar.name, quantity)
    Gabba::Gabba.new("UA-750037-13", "#{site.subdomain ? site.subdomain : "www"}.buddybeers.com").event("Sales", "Ordered", price_name, total.exchange_to("USD").to_s)
  end

  def paid!
    unless paid?
      transaction do
        update_attributes(:paid => true, :status => "valid", :paid_at => DateTime.now())
        group_drinks.each do |group_drink|
          group_drink.update_attributes(:paid => true, :status => "valid", :paid_at => DateTime.now())
          
          group_drink.quantity.times do |quantity_count|
            voucher = bar.vouchers.available.where(:cents => group_drink.cents / group_drink.quantity).where(:currency => group_drink.currency).first
            voucher.claim!(group_drink) unless voucher.blank?
          end 
        end
        #quantity.times { bar.vouchers.available.where(:cents => cents / quantity).where(:currency => currency).first.claim!(self) }
        send_notification!
        schedule_expiration!
        #track! if Rails.env.production?
        group_drinks.each do |group_drink|
          group_drink.track! if Rails.env.production?
          group_drink.create_fb_app_requests if group_drink.recipient_facebook_uid.present? and sender.facebook_user?
          if sender.present? and recipient.present?
            Friendship.find_or_create_by_user_id_and_friend_id(:user_id => sender_id, :friend_id => group_drink.recipient_id)
          end
        end
      end
    end
    # post_to_twitter!
    group_drinks.each do |group_drink|
      group_drink.post_to_twitter!
    end
  rescue ActiveRecord::StaleObjectError
    return reload.paid?
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
  
  def smsable?
    recipient_phone.present?
  end
  
  def emailable?
    recipient_email.present? or (recipient.present? and recipient.email.present?)
  end
  
  def facebookable?
    recipient_facebook_uid.present? or (recipient.present? and recipient.facebook_uid?)
  end

  def expire!
    unless redeemed? or expired?
      vouchers.redeemable.each do |voucher|
        # Promotional vouchers are not paid out because they are sent by the bar
        # Company_promotional vouchers are paid out because they are sent by Buddy Beers
        # We still create a line item for them for our records
        if promotional
          LineItem.create(:bar_id => bar_id, :iou_id => id, :voucher_id => voucher.id,
                          :payout_percent => 0, :status => "expired",
                          :cents => 0, :currency => voucher.currency)
        else
          LineItem.create(:bar_id => bar_id, :iou_id => id, :voucher_id => voucher.id,
                          :payout_percent => 100 - bar.percent_expired_cut, :status => "expired",
                          :cents => voucher.total.cents * (100 - bar.percent_expired_cut) / 100.0, :currency => voucher.currency)
        end
      end
      self.update_attributes(:status => "expired", :expired => true)
    end
  end

  def expired?
    expired and status == "expired"
  end
  
  # attributes
  def price_in_bucks
    total.exchange_to("USD").cents #base currency is USD
  end
  
  # Custome validation
  def validate_group_drinks
    rnt = true
    gps = group_drinks
    unless gps.blank?
      gps.each do |gp|
        rnt = false if !gp.recipient_name.blank? && (!gp.recipient_email.blank? || !gp.recipient_phone.blank?) && !gp.price_id.blank? && !gp.cents.blank?
      end
    end
    
    if rnt
      errors.add(:base, "Group drinks should not be blank")
      return false 
    end
  end
  
end
