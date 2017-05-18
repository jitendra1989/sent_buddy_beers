class Notifier < ActionMailer::Base
  default :from => "Buddy Drinks <noreply@buddydrinks.com>"

  include ActionView::Helpers::TextHelper
  helper :application, :ious
  helper_method :current_site

  layout 'email', :except => 'payment_request_alert'

  def voucher_notification(group_drink)
    with_custom_site(group_drink.iou.site) do
      @group_drink = group_drink
      @iou = group_drink.iou
      mail :to => group_drink.recipient_email.present? ? group_drink.recipient_email : group_drink.recipient.email,
      :subject => I18n.t("notifier.voucher_notification.subject", :name => group_drink.iou.sender_name.titleize, :quantity => group_drink.quantity, :item => group_drink.price_name, :location => group_drink.iou.bar.name, :city => group_drink.iou.bar.city.name)
    end
  end

  def birthday_remainder(friend, birthday_guy)
    @birthday_guy = birthday_guy
    @friend = friend
    mail :to => friend.email,
           :subject => "Your friend #{birthday_guy.get_name.to_s.capitalize} is celebrating a birthday!"

  end

  def voucher_expires_soon(group_drink)
    with_custom_site(group_drink.iou.site) do
      @iou = group_drink.iou
      @group_drink = group_drink
      @vouchers = group_drink.iou.vouchers.redeemable
      mail :to => group_drink.recipient_email.present? ? group_drink.recipient_email : group_drink.recipient.email,
           :subject => I18n.t("notifier.voucher_expires_soon.subject", :count => @vouchers.count)
    end
  end

  def email_activation(email)
    @email = email
    mail :to => email.email,
         :subject => I18n.t("notifier.email_activation.subject")
  end

  def new_voucher_list(voucher_list)
    @voucher_list = voucher_list
    #attachments[[I18n.t("affiliate.bars.voucher_list.pdf_file_name"), @voucher_list.cents, @voucher_list.id, ".pdf"].join("_")] = File.read(affiliate_bar_voucher_list_url(:bar_id => @voucher_list.bar_id, :id => @voucher_list.id, :format => "pdf"))
    mail :to => [voucher_list.bar.affiliate.present? ? voucher_list.bar.affiliate.email : voucher_list.bar.contact_email, "info@buddydrinks.com", (voucher_list.bar.bro ? voucher_list.bar.bro.email : nil)].compact.join(", "),
         :subject => I18n.t("notifier.new_voucher_list.subject")
  end

  def new_bar_signup(bar)
    @bar = bar
    mail :to => bar.contact_email,
         :subject => "[IMPORTANT] A New Venue Has Signed Up!",
         :cc => "venuesignup@buddydrinks.com"
  end

  def payment_made(payment)
    @payment = payment
    mail :to => payment.affiliate.email,
    :subject => I18n.t("notifier.payment_made.subject", :number => payment.id, :amount => "#{payment.amount.to_s} #{payment.amount.currency.symbol}")
  end

  def outstanding_balance(affiliate)
    @affiliate = affiliate
    mail :to => affiliate.email,
         :subject => I18n.t("notifier.outstanding_balance.subject")
  end

  def sms_error(passed_parameters, message)
    @passed_parameters = passed_parameters
    @message = message
    mail :to => "info@buddydrinks.com",
         :subject => "[IMPORTANT] SMS Error"
  end

  def credit_event_error(credit_event, up_params, message, error_count=1)
    @credit_event = credit_event
    @up_params = up_params
    @message = message
    @error_count = error_count
    mail :to => "info@buddydrinks.com",
         :subject => "[IMPORTANT] Credit Event Error"
  end

  def notify_employee(employment)
    @employment = employment
    mail :to => @employment.user.reload.email,
         :subject => I18n.t("notifier.notify_employee.subject", :bar => @employment.bar.name)
  end

  def redeemed_voucher_report(bar, timeframe, vouchers)
    with_custom_site(bar.sites.first) do
      @bar = bar
      @timeframe = timeframe
      @vouchers = vouchers
      mail :to => @bar.affiliate.email,
      :subject => I18n.with_locale(@bar.affiliate.language.to_sym) { I18n.t('notifier.redeemed_voucher_report.subject', :location_name => @bar.name, :time_frame => I18n.t("notifier.redeemed_voucher_report.timeframes.#{@timeframe.to_s}"))}
    end
  end

  def email_invitation(email)
    mail :to => email.email,
    :subject => t('notifier.email_invitation.subject')
  end

  def contect_us(params)
    mail(:to => "malfieri@buddydrinks.com",
    :subject => "Contact us - (#{params["contact"]["name"]})", :body=> params["contact"]["question"])
  end
  
  def get_information(information_send) 
    @information_send = information_send
    mail(:to => "oboukottaya@buddydrinks.com",
    :subject => "Information -") do |format|
      format.html { render :layout => false }
    end            
  end

  def payment_request_alert(marchent=nil, paid_amount=0.0, admin=nil, total_vouchers=nil)
    @marchent = marchent
    @paid_amount = paid_amount
    @admin = admin
    @total_vouchers = total_vouchers
    mail :to => @admin.emails.first.email,
         :subject => "Marchent Payment Request Alert"
  end

  private

  def with_custom_site(site)
    yield and return if site == current_site

    begin
      old_current_site = current_site
      old_view_paths   = self.view_paths

      self.current_site = site
      site_pathset = CustomViewPaths.pathsets[site.code_name]
      self.lookup_context.view_paths = site_pathset + old_view_paths[2..-1]

      yield
    ensure
      self.current_site = old_current_site
      self.lookup_context.view_paths = old_view_paths
    end
  end

  def current_site=(site)
    Thread.current[:current_site] = site
  end

end
