require 'net/https'
require 'timeout'

class RedeemedVoucherEmailJob < Struct.new(:timeframe)
  
  # Sends redeemed voucher reports to bar and then reschedules it for timeframe.
  # there should only be 3 instances of this job running at all times, daily, weekly, monthly
  
  TIMEOUT_SECONDS = 3000

  def perform
    Timeout::timeout(TIMEOUT_SECONDS) do
      Bar.where(:redeemed_voucher_notification_timeframe => timeframe).each do |bar|
        bar.send_redeemed_voucher_report!
      end
    end
    case timeframe
    when "daily"  
      Delayed::Job.enqueue RedeemedVoucherEmailJob.new("daily"), {:priority => 0, :run_at => 1.day.from_now.beginning_of_day}
    when "weekly"
      Delayed::Job.enqueue RedeemedVoucherEmailJob.new("weekly"), {:priority => 0, :run_at => 1.week.from_now.beginning_of_day}
    when "monthly"
      Delayed::Job.enqueue RedeemedVoucherEmailJob.new("monthly"), {:priority => 0, :run_at => 1.month.from_now.beginning_of_day}
    end
  end
end