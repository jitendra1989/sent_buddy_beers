class PayoutModel < ActiveRecord::Base
  belongs_to :bar

  validates_presence_of :bar_id, :low_cents, :currency, :percent_payout
  validates_numericality_of :low_cents, :percent_payout
  validates_numericality_of :high_cents, :allow_nil => true
end
