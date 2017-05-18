# encoding: UTF-8

class Voucher < ActiveRecord::Base

  include Discountable
  include ActionView::Helpers::NumberHelper # So we can use number_to_currency
  include ActionView::Helpers::TextHelper
  
  belongs_to :bar
  belongs_to :iou
  belongs_to :group_drink
  belongs_to :voucher_list#, :touch => true #elegant but not really working because of the voucher generation process

  has_many :line_items
  has_many :paid_vouchers

  scope :taken, where("iou_id IS NOT NULL")
  scope :redeemable, where("iou_id IS NOT NULL AND redeemed = ? AND ious.expired = ?", false, false).includes(:iou)
  scope :valid, where(:redeemed => false)
  scope :redeemed, where(:redeemed => true)
  scope :expired, where("ious.expired = ? AND redeemed = ?", true, false).includes(:iou)
  scope :available, where(:iou_id => nil)
  scope :expired_since, lambda { |date| where("ious.status = 'expired' AND ious.expired = ? AND ious.expires_at >= ?", true, date).includes(:iou) }
  scope :for_site_ids, lambda { |ids| select("DISTINCT(vouchers.*)").joins(:bar => :sites).where(:sites => { :id => ids }) }
  scope :for_site_admin, lambda { |site_admin| for_site_ids(site_admin.site_ids) }
  scope :for_affiliate, lambda { |affiliate| where("iou_id IS NOT NULL AND redeemed = ?", false).where(:bar_id => affiliate.bar_ids) }
  scope :for_employee, lambda { |employee| where("iou_id IS NOT NULL AND redeemed = ?", false).where(:bar_id => employee.employer_ids) }
  scope :for_user, lambda { |user| where("iou_id IS NOT NULL AND redeemed = ? AND ious.status != 'expired' AND ious.recipient_id = ?", false, user.id).includes(:iou) }

  validates_presence_of :token, :redemption_token
  validates_uniqueness_of :token

  before_validation :set_tokens
  
  after_save :update_iou_status, :if => :redeemable?

  attr_accessor :redemption_code

  def code
    "#{token.first(1)}-#{token.last(3)}"
  end

  def coupon
    "#{code}-#{redemption_token}"
  end

  def claim!(group_drink)
    update_attributes!(:iou => group_drink.iou, :group_drink => group_drink, :discounted_cents => group_drink.discounted_cents / group_drink.quantity, :discounted => group_drink.discounted)
    voucher_list.save #in order to archive or close
  end

  def redeem!
    write_attribute(:redeemed, true)
    write_attribute(:redeemed_at, DateTime.now)
    # Promotional vouchers are not paid out because they are sent by the bar
    # Company_promotional vouchers are paid out because they are sent by Buddy Beers
    # We still create a line item for them for our records
    if iou.promotional
      LineItem.create(:bar_id => bar_id, :iou_id => iou_id, :voucher_id => id,
                      :payout_percent => 0, :status => "redeemed",
                      :cents => 0, :currency => currency)
    else
      LineItem.create(:bar_id => bar_id, :iou_id => iou_id, :voucher_id => id,
                      :payout_percent => payout_model.percent_payout, :status => "redeemed",
                      :cents => total.cents * payout_model.percent_payout / 100.0, :currency => currency)
    end
    voucher_list.save
    Gabba::Gabba.new("UA-750037-13", "#{iou.site.subdomain ? iou.site.subdomain : "www"}.buddybeers.com").event("Vouchers", "Redemption", iou.bar.name) if Rails.env.production?
  end

  def redeemable?
    iou.present? and not redeemed
  end

  def available?
    iou.blank?
  end

  def taken?
    not available?
  end

  def update_iou_status
    iou.update_attribute(:status, "redeemed") if iou.vouchers(true).all?(&:redeemed?)
  end

  delegate :to_s, :to => :code

  def set_tokens
    write_attribute(:token, String.tokenize(4)) if token.blank?
    write_attribute(:redemption_token, String.tokenize(2)) if redemption_token.blank?
  end

  def date
    self.iou.created_at.to_date
  end

  def redemption_code=(redemption_code)
    redeem! if redemption_token.present? and redemption_code.upcase == redemption_token.upcase
  end

  def payout_model
    bar.payout_models.first(:conditions => ['low_cents <= ? AND high_cents >= ? OR low_cents <= ? AND high_cents IS NULL', total.cents, total.cents, total.cents])
  end
end
