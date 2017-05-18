class Payment < ActiveRecord::Base
  belongs_to :affiliate

  has_many :line_items

  validates_presence_of :affiliate_id, :beginning_at, :ending_at

  composed_of :amount,
              :class_name => "Money",
              :mapping => [%w(cents cents), %w(currency currency_as_string)],
              :constructor => Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) },
              :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : raise(ArgumentError, "Can't convert #{value.class} to Money") }

  scope :outstanding, where(:paid => false)
  scope :processed, where(:paid => true)

  before_save :calculate_total

  def paid!
    update_attribute(:paid, true)
    update_attribute(:paid_at, DateTime.now)
    Notifier.payment_made(self).deliver if self.affiliate and self.cents > 0
  end

  def calculate_total
    if line_items.present?
      sum = line_items.map(&:amount).sum
      self.amount = sum
    else
      self.amount = Money.new(0, affiliate.default_currency)
    end
  end
end
