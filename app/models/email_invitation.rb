class EmailInvitation < ActiveRecord::Base
  
  # This is the class we use to send links to our mobile app download page from the /apps page. That's it.
  
  belongs_to :user
  
  scope :sent, where('delivered_at is not null')
  
  belongs_to :user

  validates_presence_of :email
  validates_format_of :email, :with => Devise.email_regexp, :message => I18n.t("activerecord.errors.messages.look_like_email")

  before_validation :remove_leading_and_trailing_spaces, :downcase!, :link_existing_user
  after_save :send!
  
  def sent?
    delivered_at.present?
  end
  
  def remove_leading_and_trailing_spaces
    email.strip! if email.is_a?(String)
  end
  
  def send!
    Notifier.email_invitation(self).deliver
  end
  
  def downcase!
    email.try(:downcase)
  end
  
  def link_existing_user
    unless user_id
      emails = Email.with_email_like(email)
      if emails.present?
        user_id = emails.first.user_id
      end
    end
  end
end
