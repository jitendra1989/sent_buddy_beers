class Affiliate < User
  has_many :bars
  has_many :payments
  has_many :payouts
  has_many :paid_voucher_details

  default_scope :order => 'name ASC'
  
  scope :for_site_ids, lambda { |site_ids| select("DISTINCT(users.*)").joins(:bars => :sites).where(:sites => {:id => site_ids}).readonly(false) }
  scope :for_site_admin, lambda { |site_admin| for_site_ids(site_admin.site_ids) }

  def create_payment!(from=1.month.ago.beginning_of_month, to=1.month.ago.end_of_month)
    
    # Send an outstanding balance email if the affiliate has outstanding balance:
    Notifier.outstanding_balance(self).deliver if ((self.outstanding_balance.cents > 0) and self.email.present?)
    
    payment = self.payments.create(:beginning_at => from, :ending_at => to, :affiliate_name => self.name, :notes => "", :admin_notes => "")
    #income = Money.new(0, :currency => self.default_currency)
    bars.each do |bar|
      #profit = bar.profit(from, to)
      #income += profit
      payment.line_items << bar.line_items.all(:conditions => ["created_at BETWEEN ? AND ?", from, to])
      profit = bar.profit(from, to)
      payment.notes += "#{bar.name} (#{profit} #{profit.is_a?(Money) ? profit.currency : bar.default_currency})\n"
      payment.admin_notes += "#{bar.name} At: #{bar.percent_cut}% Redeemed and #{bar.percent_expired_cut}% Expired\n"
    end
    #payment.amount = income
    payment.save #unless income.cents == 0
  end

  def payment_prefs_empty?
    return false if paypal_email.present?
    # All Accounts Need:
    return true if bank_account_name.blank? and bank_account_number.blank?
    # European Accounts Need:
    if bank_account_bank_code.blank?
      return true if (bank_account_iban.blank? and bank_account_bic_swift.blank?)
    else
      return false
    end
  end

  def outstanding_balance
    if payments.blank?
      balance = Money.new(0, self.default_currency)
    else
      balance = payments.outstanding.all.sum(&:amount)
    end
    balance = Money.new(0, self.default_currency) if (balance.is_a?(Fixnum) and balance == 0)
    return balance
  end
  
  def subscribe_to_mailchimp!
    if confirmed_at.present?
      gb = Gibbon::API.new("4d33aaab5917dc47cb8f166c3f92c3ed-us1")

      list_id = "3199191d4a"

      mailchimp_attr = {
          :id => list_id,
          :email_address => email,
          :update_existing => true,
          :merge_vars => { 
            :groupings => [{'name' => 'Language', 'groups' => language == "de" ? "German" : "English"}],
            :optin_time => confirmed_at.to_s(:db),
            :fname => (to_s.split(" ") - [to_s.split(" ").last]).join(" "),
            :lname => to_s.split(" ").last
          },
          :double_optin => false
         }

      mailchimp_attr[:merge_vars].merge!({:optin_ip => last_sign_in_ip}) if last_sign_in_ip.present?

      response = gb.list_subscribe(mailchimp_attr)
    end
  end
end
