require 'net/https'
require 'timeout'

class BatchEmailJob < Struct.new(:bar_id)
  TIMEOUT_SECONDS = 180

  def perform
    Timeout::timeout(TIMEOUT_SECONDS) do
      bar = Bar.find(bar_id, :include => :ious)
      if bar.active
        # Only send emails when the voucher length has changed
        # if bar.outstanding_ious_count != bar.ious.outstanding.length
        #   I18n.locale = bar.affiliate.language # Set Language
        #
        #   # Send email
        #   Notifier.outstanding_ious(bar, bar.ious.outstanding).deliver unless bar.ious.outstanding.blank?
        #
        #   # update counter cache
        #   bar.outstanding_ious_count == bar.ious.outstanding.length
        #   bar.save
        #end
        #bar.queue_emails!
        # Todo: remove this job when we launch the new system
      end
    end
  end
end
