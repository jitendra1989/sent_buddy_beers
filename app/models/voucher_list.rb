class VoucherList < ActiveRecord::Base
  belongs_to :bar
  has_many :vouchers, :order => "vouchers.token ASC"
  
  default_scope :order => 'cents ASC'
  scope :valid, where(:archived => false)
  scope :archived, where(:archived => true)
  scope :closed, where(:closed => true)

  composed_of :amount,
              :class_name => "Money",
              :mapping => [%w(cents cents), %w(currency currency_as_string)],
              :constructor => Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) },
              :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : raise(ArgumentError, "Can't convert #{value.class} to Money") }

  before_create :generate
  before_update :close, :archive
  
  after_update :prepare
  # after_touch :prepare 
  # causing 'prepare' to run 50 times during generate method which causes a new voucher list to be constantly 
  # generated do to the vouchers being taken when there are none
  after_create :notify

  def self.find_or_create_by_price(price)
    VoucherList.find_or_create_by_bar_id_and_cents_and_currency_and_archived_and_closed(price.bar_id, price.cents, price.currency.to_s, false, false)
  end
  
  def expires_at
    Voucher.unscoped.includes(:iou).taken.where(:voucher_list_id => id).order("ious.expires_at").try(:last).try(:iou).try(:expires_at)
  end
  
  def previous
    VoucherList.unscoped.where(:bar_id => bar.id, :cents => cents).order("id desc").where("id < #{id}").try(:first)
  end
  
  def next
    VoucherList.unscoped.where(:bar_id => bar.id, :cents => cents).order("id asc").where("id > #{id}").try(:first)
  end
  
  def downloaded!
    update_attribute(:downloaded, true)
  end

  protected

  def prepare
    if vouchers.reload.all?(&:taken?) and bar.reload.tiers.include?([cents, currency])
      VoucherList.find_or_create_by_price(Price.new(:bar => bar, :cents => cents, :currency => currency))
    end
  end

  def close
    write_attribute(:closed, vouchers(true).all?(&:taken?)) or true
  end

  def archive
    write_attribute(:archived, vouchers(true).all?(&:redeemed?)) or true
  end

  def generate
    until vouchers.size >= 50
      voucher = Voucher.new(:voucher_list => self, :bar => bar, :cents => cents, :currency => currency)
      vouchers << voucher if voucher.valid?
    end
    # 20.times { vouchers.build(:bar => bar, :cents => cents, :currency => currency) }
  end
  
  def notify
    if bar.voucher_lists.closed(true).where(:cents => cents, :currency => currency).present?
      Notifier.new_voucher_list(self).deliver if bar.active? and bar.new_voucher_list_notification
    end
  end
end
