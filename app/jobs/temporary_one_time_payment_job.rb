# This job creates an invoice for the gap between whenever we deployed the redeemed_at
# attributes and the next month

require 'timeout'

class TemporaryOneTimePaymentJob < Struct.new(:affiliate_id, :from, :to)
  TIMEOUT_SECONDS = 460

  def perform
    Timeout::timeout(TIMEOUT_SECONDS) do
      affiliate = Affiliate.find(affiliate_id)
      affiliate.create_payment!(from, to)
    end
  end
end
