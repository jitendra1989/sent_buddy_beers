require 'net/https'
require 'timeout'

class ExpireIouJob < Struct.new(:iou_id)
  TIMEOUT_SECONDS = 180

  def perform
    Timeout::timeout(TIMEOUT_SECONDS) do
      iou = Iou.find(iou_id)
      iou.group_drinks.each do |group_drink|
        if group_drink.expires_at <= Date.today.beginning_of_day
          group_drink.expire!
        else
          Delayed::Job.enqueue ExpireIouJob.new(iou_id), {:priority => 0, :run_at => Date.tomorrow.beginning_of_day}
        end
      end
    end
  end
end
