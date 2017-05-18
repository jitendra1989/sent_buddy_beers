module Discountable
  extend ActiveSupport::Concern

  # Model must have :cents (integer), :currency (:string), :discounted_cents (integer) and :discounted (boolean)

  # amount: is the total net-worth of the object, so the full-priced drink, voucher amount, etc.
  # discounted_amount: is the discounted price of the object, so the price the user pays to get the amount above

  included do
    composed_of :amount,
                     :class_name => "Money",
                     :mapping => [%w(cents cents), %w(currency currency_as_string)],
                     :constructor => Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) },
                     :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : raise(ArgumentError, "Can't convert #{value.class} to Money") }

    composed_of :discounted_amount,
                     :class_name => "Money",
                     :mapping => [%w(discounted_cents cents), %w(currency currency_as_string)],
                     :constructor => Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) },
                     :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : raise(ArgumentError, "Can't convert #{value.class} to Money") }

    # validates_numericality_of :cents, :greater_than => 0
    #validates_numericality_of :discounted_cents
    #validates_numericality_of :discounted_cents, :greater_than => 0, :if => :discounted?
    #validates_each :discounted_cents do |record, attr, value|
      #record.errors.add attr, I18n.t('activerecord.errors.messages.less_than_regular_price') if record.discounted and value >= record.cents
    #end
  end

  # total: shows the correct amount depending upon whether or not the price is discounted.
  # this is helpful if you only want to show one price for a product, say in a drink list
  module InstanceMethods
    def total
      #self.discounted ? self.discounted_amount : self.amount
      self.amount
    end
    
    def cents_virtual
      self.amount.exchange_to("USD").cents
    end
    
    def discounted_cents_virtual
      self.discounted_amount.exchange_to("USD").cents
    end
  end
end
