class BacklogOldPayments < ActiveRecord::Migration
  def self.up
    # Affiliate.all.each do |affiliate|
    #       #payment = affiliate.payments.new(:beginning_at => 8.months.ago.beginning_of_month, :ending_at => DateTime.now, :affiliate_name => affiliate.name, :notes => "", :admin_notes => "")
    #       #income = Money.new(0, :currency => affiliate.default_currency)
    #       affiliate.bars.each do |bar|
    #         # some of the old bars have ious with no vouchers and vouchers with no redeemed_at date.
    #         #profit = Money.new(0, :currency => bar.default_currency)
    #         @valid_ious = bar.ious.paid.all(:conditions => ["updated_at BETWEEN ? AND ?", 8.months.ago.beginning_of_month, DateTime.now])
    #         @valid_ious.each do |iou|
    #           if iou.vouchers.present?
    #             profit += Money.new(iou.vouchers.redeemed.all.sum(&:cents) * (100 - bar.percent_cut) / 100.0, :currency => bar.default_currency)
    #             profit += Money.new(iou.vouchers.expired.all.sum(&:cents) * (100 - bar.percent_expired_cut) / 100.0, :currency => bar.default_currency)
    #           elsif iou.expired?
    #             profit += Money.new(iou.price_cents * (100 - bar.percent_expired_cut) / 100.0, :currency => bar.default_currency)
    #           elsif iou.status = "redeemed"
    #             profit += Money.new(iou.price_cents * (100 - bar.percent_cut) / 100.0, :currency => bar.default_currency)
    #           end  
    #         end
    #         income += profit
    #         payment.notes += "#{bar.name} (#{profit} #{profit.currency})\n"
    #         payment.admin_notes += "#{bar.name} At: #{bar.percent_cut}% Redeemed and #{bar.percent_expired_cut}% Expired\n"
    #       end
    #       payment.amount = income
    #       payment.save unless income.cents == 0
    #       Delayed::Job.enqueue TemporaryOneTimePaymentJob.new(affiliate.id, DateTime.now, DateTime.now.end_of_month), 0, 1.month.from_now.beginning_of_month # If it's SEP, this will run OCT 1st
    #     end
    #     Delayed::Job.enqueue CreateMonthlyInvoicesJob.new, 0, 1.month.ago.next_month.next_month.next_month.beginning_of_month #If we're in SEP this will be Nov 1st (making a billing for oct)
    #   
    
    # Time frame
    from = "2010-04-01"
    to = DateTime.now
    
    # for each affiliate
    Affiliate.all.each do |affiliate|
      # we want to cycle through their bars
      affiliate.bars.each do |bar|
        # and get all the ious that were redeemed or expired up until now
        bar.ious.paid.each do |iou|
          # if the iou has vouchers that means it's part of the new system. 
          if iou.vouchers.present?
            # lets check if any bars have redeemed any vouchers
            iou.vouchers.redeemed.each do |voucher|
              # let's create a line item for each voucher
              LineItem.create(:bar_id => bar.id, :iou_id => iou.id, :voucher_id => voucher.id, 
                        :payout_percent => 100.0 - bar.percent_cut, :status => "redeemed", 
                        :cents => voucher.cents * (100 - bar.percent_cut) / 100.0, :currency => voucher.currency)
            end
            # or if they've expired
            iou.vouchers.expired.each do |voucher|
              # we'll also create a line item
              LineItem.create(:bar_id => bar.id, :iou_id => iou.id, :voucher_id => voucher.id, 
                        :payout_percent => 100.0 - bar.percent_expired_cut, :status => "expired", 
                        :cents => voucher.cents * (100 - bar.percent_expired_cut) / 100.0, :currency => voucher.currency)
            end
          # so if there's no vouchers we're dealing with an old iou, let's check if it's expired  
          elsif iou.expired?
            # if it is, we'll create a line item for it
            LineItem.create(:bar_id => bar.id, :iou_id => iou.id, :voucher_id => nil, 
                        :payout_percent => 100.0 - bar.percent_expired_cut, :status => "expired", 
                        :cents => iou.price_cents * (100 - bar.percent_expired_cut) / 100.0, :currency => iou.currency)
          # but if the iou was redeemed
          elsif iou.status = "redeemed"
            # we'll also create a line item
            LineItem.create(:bar_id => bar.id, :iou_id => iou.id, :voucher_id => nil, 
                        :payout_percent => 100.0 - bar.percent_cut, :status => "redeemed", 
                        :cents => iou.price_cents * (100 - bar.percent_cut) / 100.0, :currency => iou.currency)
          end
        # that should do it for each bar's ious
        end
      # that should do it for each bar
      end
      affiliate.create_payment!(from, to)     
      Delayed::Job.enqueue TemporaryOneTimePaymentJob.new(affiliate.id, to, DateTime.now.end_of_month), 0, 1.month.from_now.beginning_of_month # If it's SEP, this will run OCT 1st           
    end
    Delayed::Job.enqueue CreateMonthlyInvoicesJob.new, 0, 1.month.ago.next_month.next_month.next_month.beginning_of_month #If we're in SEP this will be Nov 1st (making a billing for oct)
  end

  def self.down
  end
end
