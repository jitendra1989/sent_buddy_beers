class LineItem < ActiveRecord::Base

  belongs_to :payment
  belongs_to :bar
  belongs_to :iou
  belongs_to :voucher

  composed_of :amount,
              :class_name => "Money",
              :mapping => [%w(cents cents), %w(currency currency_as_string)],
              :constructor => Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) },
              :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : raise(ArgumentError, "Can't convert #{value.class} to Money") }

  scope :redeemed, where(:status => "redeemed")
  scope :expired, where(:status => "expired")
end
