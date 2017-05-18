require 'timeout'

class VoucherReminderJob < Struct.new(:iou_id)
  TIMEOUT_SECONDS = 180

  def perform
    Timeout::timeout(TIMEOUT_SECONDS) do
      iou = Iou.find(iou_id)
      iou.group_drinks.each do |group_drink|
        unless group_drink.iou.vouchers.all?(&:redeemed?)
          Notifier.voucher_expires_soon(group_drink).deliver if group_drink.emailable?
          if group_drink.smsable? 
            I18n.with_locale(iou.sender.language) do
              iou.send_sms!(iou.vouchers.redeemable.count == 1 ? I18n.t("sms.reminder_singular", :item => group_drink.price_name, :name => iou.sender_name) : I18n.t("sms.reminder_plural", :count => iou.vouchers.redeemable.count, :item => group_drink.price_name, :name => iou.sender_name)) 
            end
          end
        end
      end
      
      #TODO
      # if iou.facebookable?
    end
  end
end
