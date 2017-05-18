class User < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :rememberable, :registerable, :trackable, :confirmable, :omniauthable, :token_authenticatable, :encryptable, :encryptor => :authlogic_sha512

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'login'
  attr_accessor :username
  attr_accessor :phone_number_country_code

  # for authenticating with email or login
  # from https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign_in-using-their-username-or-email-address
  #attr_accessible :login, :username
  # This is borking the new user signup for some reason

  before_validation :strip_phone_number, :join_phone_numbers

  after_update :sync_pending_ious, :if => :active_for_authentication?

  # Make sure the user has an auth token so they can use the API
  before_save :ensure_authentication_token, :confirmation_events

  belongs_to :sign_up_site, :class_name => "Site"
  has_many :sent_ious, :foreign_key => 'sender_id', :class_name => "Iou", :conditions => ["status = 'valid' OR status = 'redeemed' OR status = 'expired'"], :order => "created_at DESC"
  has_many :received_ious, :foreign_key => 'recipient_id', :class_name => "Iou",  :conditions => ["status = 'valid' OR status = 'redeemed' OR status = 'expired'"], :order => "status DESC, expires_at DESC"
  has_many :received_group_drinks, :foreign_key => 'recipient_id', :class_name => "GroupDrink",  :conditions => ["status = 'valid' OR status = 'redeemed' OR status = 'expired'"], :order => "status DESC, expires_at DESC"
  has_many :credit_events
  has_many :emails, :dependent => :destroy
  has_many :vouchers, :through => :received_ious
  has_many :received_facebook_requests, :foreign_key => "recipient_id", :class_name => "FacebookRequest", :primary_key => "facebook_uid", :dependent => :delete_all
  has_many :sent_facebook_requests, :foreign_key => "sender_id", :class_name => "FacebookRequest", :primary_key => "facebook_uid", :dependent => :delete_all
  has_many :metrics
  has_many :facebook_app_credentials, :order => "updated_at DESC", :dependent => :destroy
  has_many :email_invitations
  has_many :events

  # ============================================================================================#
  # A user can be an employee of a bar. This is managed by the join table, employments
  # We call the user's bars employers here just to seperate them from the Affiliate model
  # who actually "owns" bars.
  #
  # -tjt
  # ============================================================================================#
  has_many :employments, :dependent => :destroy
  has_many :employers, :through => :employments, :source => :bar, :uniq => true

  # ============================================================================================#
  # This is the self-referential relationship that allows users to be friends with each other.
  # The relationship links one user to another 'through' the friendship model. Check out the
  # friendship model for more information but basically:
  #
  # This allows you to call @user.friendships and get all the user's friendships but also call
  # @user.friends to return an array of the user's freinds (as user instances)
  #
  # -tjt
  # ============================================================================================#
  has_many :friendships, :dependent => :delete_all
  has_many :friends, :through => :friendships

  validates :language, :presence => true
  validates :phone_number, :numericality => true, :length => {:minimum => 7}, :uniqueness => true, :allow_blank => true
  validates :login, :presence => true, :uniqueness => true
  # validates :birthday_day, :presence => true

  with_options :if => :password_required? do |v|
    v.validates_presence_of     :password
    v.validates_confirmation_of :password
    v.validates_length_of       :password, :within => 4..20, :allow_blank => true
  end

  accepts_nested_attributes_for :emails, :allow_destroy => true
  accepts_nested_attributes_for :facebook_app_credentials, :allow_destroy => true

  scope :active, where("users.confirmed_at IS NOT NULL").order("name ASC")
  scope :with_email_like, lambda {|query| joins(:emails).where("UPPER(emails.email) like ?", "%#{query.try(:upcase)}%")}
  scope :like, lambda {|query| joins(:emails).where("UPPER(emails.email) like ? OR UPPER(name) like ? OR UPPER(login) like ?", "%#{query.try(:upcase)}%", "%#{query.try(:upcase)}%", "%#{query.try(:upcase)}%")}
  scope :find_user_with_created_at, lambda { |beginning_date, end_date| where("created_at >= ? AND created_at <= ?", beginning_date, end_date) }
  #~ has_attached_file :avatar, :storage => :s3,
                    #~ :s3_credentials => "#{Rails.root}/config/s3.yml",
                    #~ :path => "/:style/:filename",
                    #~ :styles => { :thumb => "75x75#", :square => "100x100#", :tiny => "48x48#" }
                    #~ 
  paperclip_opts = {
    :styles => { :thumb => "75x75#", :square => "100x100#", :tiny => "48x48#" }
  }

  unless Rails.env.development?
    paperclip_opts.merge! :storage        => :s3,
                          :s3_credentials => "#{Rails.root}/config/s3.yml",
                          :path => "/:style/:filename"
  end

  has_attached_file :avatar, paperclip_opts

  def to_s
    #name.present? ? name : login.present? ? login : emails.primary.first.to_s.split("@").first
    name.present? ? name : emails.primary.first.to_s.split("@").first
  end

  def get_name
    name.present? ? name : login.present? ? login : emails.primary.first.to_s.split("@").first
  end

  def delete_pic?
    self.avatar = nil
    self.save!
  end

  def email
    emails.primary.first.to_s
  end

  def affiliate?
    is_a?(Affiliate)
  end

  def bro?
    is_a?(Bro)
  end

  def admin?
    is_a?(Admin)
  end

  def site_admin?
    is_a?(SiteAdmin)
  end

  def employee?
    employments.exists?
  end

  def primary_email
    first_primary_email = ""
    first_primary_email = emails.where(:primary => 'true').order("created_at").first unless emails.blank?
    first_primary_email.email unless first_primary_email.blank?
  end

  def get_formatted_date_to_calender
    birthdate = self.birthday_day
    today_date = Date.today
    after_15_day = today_date + 15.days
    if (self.birthday_day.month == 1 && Date.today.month == 12)
      dob = self.birthday_day.to_date.change(:year => after_15_day.year)
    else
      dob = birthdate.to_date.change(:year => today_date.year)
    end
    "#{dob.year}-#{self.birthday_day.strftime("%m-%d")}"
  end

  def display_all_email
    unless emails.blank?
      email_h = {}
      emails.each do |email|
        unless email.email == email.user.primary_email
          email_h[email.id] = email.email
        end
      end
      email_h
      #emails.inject({}) {|h, email| h.merge( email.id  => email.email) if email.primary != true}
    end
  end
  def self.get_users
    @users = @users || User.all
  end
  # We're not using this but we can if we want to have the user add a password when they activate their account
  # we need to make sure that either a password or openid gets set
  # when the user activates his account
  # def has_no_credentials?
  #   self.crypted_password.blank? #&& self.openid_identifier.blank?
  # end

  # We're also not using this code right now
  # takes care of setting any data that you want to happen at signup
  # (aka before activation)
  # def signup!(params, user_type)
  #     self.name = params[user_type][:name]
  #     self.emails_attributes = params[user_type][:emails_attributes]
  #     self.login = params[user_type][:login]
  #     self.password = params[user_type][:password]
  #     self.password_confirmation = params[user_type][:password_confirmation]
  #     save_without_session_maintenance
  #   end

  # takes care of setting any data that you want to happen at activation.
  # at the very least this will be setting active to true
  # and setting a pass, openid, or both.

  def activate_email
    if emails.reload.primary.first
      email = emails.primary.first
      email.pending = false
      self.errors.add[:base] << email.errors.full_messages unless email.save
    end
  end

  def sync_pending_ious
    ious = []
    ious << Iou.where(:recipient_email => emails.verified.collect{|e| e.to_s }, :recipient_id => nil)
    ious << Iou.where(:recipient_facebook_uid => facebook_uid.to_s, :recipient_id => nil) if facebook_user?
    ious << Iou.where(:recipient_phone => phone_number.to_s, :recipient_id => nil) if phone_number.present?
    ious.flatten.each{ |iou| iou.update_attribute(:recipient_id, self.id) }
  end

  def strip_phone_number
    # This will strip all the weird characters the user enters and then to_i will delete any leading zeros
    unless phone_number.blank?
      self.phone_number = phone_number.to_s.gsub(/[^0-9]/, "").to_i
    end
  end

  def join_phone_numbers
    unless phone_number.to_s.starts_with?(phone_number_country_code) or phone_number.blank?
      self.phone_number = [phone_number_country_code, phone_number].join().to_i
    end
  end

  def ious
    (sent_ious + received_ious).flatten
  end

  def can_redeem_vouchers?
    employee? or !is_a?(Customer)
  end

  def redeemable_vouchers
    users_vouchers = Voucher.for_user(self)
    if admin?
      users_vouchers += Voucher.taken.valid
    elsif site_admin?
      users_vouchers += Voucher.for_site_admin(self)
    elsif affiliate? or bro?
      users_vouchers += Voucher.for_affiliate(self)
    elsif employee?
      users_vouchers += Voucher.for_employee(self)
    end
    return users_vouchers.uniq
  end

  # def drunkest
  #     Iou.find_by_sql("SELECT sum(quantity) AS sum_quantity, recipient_id AS recipient_id FROM `ious` GROUP BY recipient_id  ORDER BY sum_quantity DESC").first.recipient
  #   end
  #
  #   def most_generous
  #     Iou.find_by_sql("SELECT sum(quantity) AS sum_quantity, sender_id AS sender_id FROM `ious` GROUP BY sender_id  ORDER BY sum_quantity DESC").first.sender
  #   end

  # Devise stuff
  def password_required?
    !persisted? || password.present? || password_confirmation.present?
  end

  def headers_for(action)
    if action == :confirmation_instructions
      {:to => emails.first.to_s}
    else
      {}
    end
  end

  def confirm!
    activate_email unless confirmed?
    super
  end

  def credit!(amount)
    self.update_attribute(:credits, self.credits.to_i + amount.to_i)
  end

  def debit!(amount)
    self.update_attribute(:credits, self.credits.to_i - amount.to_i)
  end

  def confirmation_events
    if self.confirmed_at_changed?
      subscribe_to_mailchimp!
    end
  end

  def subscribe_to_mailchimp!
    if active_for_authentication?
      gb = Gibbon::API.new("4d33aaab5917dc47cb8f166c3f92c3ed-us1")

      list_id = "f608d299ad"

      case language.to_s
      when "de"
        lang = "German"
      when "th"
        lang = "Thai"
      when "fr"
        lang = "French"
      when "it"
        lang = "Italian"
      else
        lang = "English"
      end

      mailchimp_attr = {
          :id => list_id,
          :email_address => email,
          :update_existing => true,
          :merge_vars => {
            :groupings => [{'name' => 'Language', 'groups' => lang}],
            :optin_time => confirmed_at.to_s(:db),
            :fname => (to_s.split(" ") - [to_s.split(" ").last]).join(" "),
            :lname => to_s.split(" ").last
          },
          :double_optin => false
         }

      mailchimp_attr[:merge_vars].merge!({:optin_ip => last_sign_in_ip}) if last_sign_in_ip.present?

      response = gb.list_subscribe(mailchimp_attr)
    end
  end

  # Facebook stuff
  def facebook_user?
    self.facebook_uid.present?
  end

  def has_fb_post_permissions_for?(site)
    return false if facebook_app_credentials.blank? or facebook_app_credentials.where(:app_id => site.facebook_app_id).blank?
    facebook_app_credentials.where(:app_id => site.facebook_app_id).first.permissions.split(",").include?("publish_stream")
  end

  def fb_access_token_for(site)
    facebook_app_credentials.where(:app_id => site.facebook_app_id).try(:first).try(:access_token)
  end

  # TODO: handle the case when signed_in_resource is not nil
  def self.find_for_facebook_oauth(access_token, sign_up_site, signed_in_resource=nil)
    #logger.debug("!!!!!!! #{access_token.inspect} !!!!!!!!")

    # access_token = {"extra" => {"user_hash" => {"id" => 1234567890, "email" => "email@email.com", "name" => "User Name"},
    #                 "credentials" => {"token" => token}}

    data = access_token["extra"]["user_hash"]
    token = access_token["credentials"]["token"]

    # Let's check the user's permissions for our app and update them on our server side
    graph = Koala::Facebook::GraphAPI.new(token)
    graph_perms_data = graph.get_object("me/permissions")
    #logger.debug("!!!!!!!!! #{graph_perms_data.inspect}")
    perms = (graph_perms_data and graph_perms_data.has_key?("data") and graph_perms_data["data"].is_a?(Array) and graph_perms_data["data"].first.present? and graph_perms_data["data"].first.keys.present?) ? graph_perms_data["data"].first.keys.join(",") : "installed, email"

    # Return user if he signed in via FB before
    if user = User.find_by_facebook_uid(data["id"])
      app_cred = FacebookAppCredential.find_or_create_by_user_id_and_site_id_and_app_id(user.id, sign_up_site.id, sign_up_site.facebook_app_id)
      app_cred.update_attributes(:access_token => token, :permissions => perms)
      user
    # If we already have such verified email in the database, connect accounts
    elsif email = Email.verified.find_by_email(data["email"])
      user = email.user
      user.update_attributes(:facebook_uid => data["id"])
      app_cred = FacebookAppCredential.find_or_create_by_user_id_and_site_id_and_app_id(user.id, sign_up_site.id, sign_up_site.facebook_app_id)
      app_cred.update_attributes(:access_token => token, :permissions => perms)
      user
    # Otherwise create a new user
    else
      Gabba::Gabba.new("UA-750037-13", "#{sign_up_site.subdomain ? sign_up_site.subdomain : "www"}.buddybeers.com").event("Users", "Signup", "classic facebook") if Rails.env.production?
      user = Customer.create! do |user|
        user.name         = data["name"]
        user.facebook_uid = data["id"]
        user.login        = data["email"].try(:parameterize).try(:to_s) # TODO: is it necessary?
        user.password     = Devise.friendly_token[0, 20]  # TODO: is it necessary?
        user.emails.build(:email => data["email"], :pending => false)
        user.facebook_app_credentials.build(:site_id => sign_up_site.id, :app_id => sign_up_site.facebook_app_id, :access_token => token, :permissions => perms)
        user.sign_up_site = sign_up_site
        user.confirmation_token = nil
        user.confirmed_at = Time.now # This activates (confirms) user
      end
      fb_profile_image = open(URI.parse("https://graph.facebook.com/#{user.facebook_uid}/picture")) 
      user.avatar = fb_profile_image
      user.save
      user
    end
  end

protected

  # for authenticating with email or login
  # from https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign_in-using-their-username-or-email-address
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    username = conditions.delete(:username)
    where(conditions).where(["UPPER(login) = :value OR UPPER(emails.email) = :value", { :value => username.upcase }]).includes(:emails).first
  end

  # Attempt to find a user by it's email. If a record is found, send new
  # password instructions to it. If not user is found, returns a new user
  # with an email not found error.
  # Attributes must contain the user email
 def self.send_reset_password_instructions(attributes={})
    #recoverable = Email.find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
    recoverable = Email.find_by_email(attributes["email"])
    if attributes["email"].blank? or recoverable.nil?
      recoverable = new
      recoverable.errors.add(:email, :non_existant)
    end
    recoverable.user.send_reset_password_instructions if recoverable.persisted?
    recoverable
  end

  # Attempt to find a user by it's email. If a record is found, send new
  # confirmation instructions to it. If not user is found, returns a new user
  # with an email not found error.
  # Options must contain the user email
  def self.send_confirmation_instructions(attributes={})
    #confirmable = find_or_initialize_with_errors(confirmation_keys, attributes, :not_found)
    confirmable = Email.find_by_email(attributes["email"])
    if attributes["email"].blank? or confirmable.nil?
      confirmable = new
      confirmable.errors.add(:email, :non_existant)
    end
    confirmable.user.resend_confirmation_token if confirmable.persisted?
    confirmable
  end
end
