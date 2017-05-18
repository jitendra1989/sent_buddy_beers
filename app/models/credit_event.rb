class CreditEvent < ActiveRecord::Base
  belongs_to :user
  belongs_to :site
  belongs_to :iou
  
  scope :buy_buddybucks, where("status_message =? AND commtype=? AND sepamount IN (?) AND iou_id IS NULL AND sn IS NOT NULL AND payment_id IS NOT NULL", "[OK]", "PAYMENT", ["10.00", "20.00", "30.00", "40.00", "50.00"])
  scope :find_buy_buddybucks_with_created_at, lambda { |beginning_date, end_date| buy_buddybucks.where("created_at >= ? AND created_at <= ?", beginning_date, end_date) }
  after_create :debit_user
  
  def debit_user
    if user.present?
      user.update_attribute(:credits, user.credits.to_i - virtualamount.to_i)
    end
  end
end
