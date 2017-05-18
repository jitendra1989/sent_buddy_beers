class StartVoucherReportDelayedJobs < ActiveRecord::Migration
  def self.up
    Delayed::Job.enqueue RedeemedVoucherEmailJob.new("daily"), {:priority => 0, :run_at => 1.day.from_now.beginning_of_day}
    Delayed::Job.enqueue RedeemedVoucherEmailJob.new("weekly"), {:priority => 0, :run_at => 1.week.from_now.beginning_of_day}
    Delayed::Job.enqueue RedeemedVoucherEmailJob.new("monthly"), {:priority => 0, :run_at => 1.month.from_now.beginning_of_day}
  end

  def self.down
  end
end
