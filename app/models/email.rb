class Email < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id, :on => :update # On update because there is no user_id when the record is being saved from the user signup form
  validates_presence_of :email
  validates_inclusion_of :pending, :in => [true, false]
  validates_inclusion_of :primary, :in => [false], :if => :requires_verification?, :message => I18n.t("activerecord.errors.messages.awaiting_verification")
  validates_format_of :email, :with => Devise.email_regexp, :message => I18n.t("activerecord.errors.messages.look_like_email")
  validates_uniqueness_of :email, :case_sensitive => false, :if => :matching_active_email?

  scope :primary, where(:primary => true)
  scope :pending, where(:pending => true)
  scope :verified, where(:pending => false)
  scope :with_email_like, lambda { |query| where("UPPER(emails.email) like ?", "%#{query.upcase}%") }

  before_validation :remove_leading_and_trailing_spaces, :downcase_email!
  before_create :set_primary_email, :generate_token
  after_save :send_activation_email, :if => :requires_verification?
  before_destroy { |email| !email.only_email? }

  def to_s
    email
  end

  def set_primary_email
    if self.user.nil? or self.user.emails.blank?
      self.primary = true
    end
  end

  def only_email?
    !user.nil? and (user.emails.verified.length == 1)
  end

  # Send an email to prompt the user for activation if they have entered a new email
  def send_activation_email
    unless notified?
      Notifier.email_activation(self).deliver
      self.update_attribute(:notified, true)
    end
  end

  def requires_verification?
    !user.nil? and !user.emails.blank? and pending?
  end

  def generate_token
    write_attribute(:token, String.tokenize)
  end
  
  def downcase_email!
    email.downcase! if email.is_a?(String)
  end

  def matching_active_email?
    # true blocks emails, false allows same
    existing_email = Email.find_by_email_and_pending(email, false)
    return false if self.user.present? and self.user.emails.include?(existing_email)
    return existing_email.present?
  end

  def remove_leading_and_trailing_spaces
    self.email.strip! if self.email.is_a?(String)
  end
end
