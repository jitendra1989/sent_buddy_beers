require 'net/https'
require 'timeout'

class IouEmailJob < Struct.new(:iou_id)
  TIMEOUT_SECONDS = 180

  def perform
    Timeout::timeout(TIMEOUT_SECONDS) do
      iou = Iou.find(iou_id)
      I18n.locale = iou.recipient ? iou.recipient.language : iou.sender.language # Set Language
      iou.send_real_notification!
    end
  end
end
