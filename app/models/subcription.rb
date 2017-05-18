class Subcription < ActiveRecord::Base

  def self.after_paypal_payment_details(iou, paypal_payer_id, paypal_token )
    self.create(:payer_id => iou.sender.id,
      :payer_name => iou.sender.name,
      :paypal_payer_id => paypal_payer_id,
      :paypal_token => paypal_token,
      :quantity => iou.quantity,
      :amount => iou.amount.to_f,
      :currency => iou.currency,
      :iou_id => iou.id
    )
  end

end
