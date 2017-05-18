# This job creates an invoice for the previous month for the specified affiliate

require 'timeout'

class CreateMonthlyInvoicesJob
  TIMEOUT_SECONDS = 460

  def perform
    Timeout::timeout(TIMEOUT_SECONDS) do
      Affiliate.all.each do |affiliate|
        affiliate.create_payment!
      end
      Delayed::Job.enqueue CreateMonthlyInvoicesJob.new, {:priority => 0, :run_at => 1.month.ago.next_month.next_month.beginning_of_month}
    end
  end
end
