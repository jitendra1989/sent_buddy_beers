class Payout < ActiveRecord::Base
  
  belongs_to :affiliate, :class_name => "Affiliate"
  validates_presence_of :affiliate_id, :payment_type
  validates_presence_of :name, :address, :if => lambda { |payout| payout.try(:payment_type) == 'cheque' }
  validates_presence_of :email, :if => lambda { |payout| payout.try(:payment_type) == 'paypal' }
end
