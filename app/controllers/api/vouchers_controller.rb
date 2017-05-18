class Api::VouchersController  < Api::BaseController
  before_filter :authenticate_user_for_api!, :get_user

  def received_1
    if @user.received_group_drinks.present?
      @vouchers = @user.received_group_drinks.paginate(:page => params[:page], :per_page => 10)
      render :json => {:success => true, :vouchers => @vouchers.collect{ |i| jsonify_vouchers(i.vouchers) }.flatten.compact, :total_pages => @vouchers.total_pages, :current_page => @vouchers.current_page }
    else
      render :json => {:success => false, :errors => [t("api.v1.vouchers.received.empty")]}
    end
  end

  def received_2
    if @user.vouchers.present?
      # @vouchers = @user.vouchers.order("redeemed, ious.expired, ious.paid_at desc").paginate(:page => params[:page], :per_page => 10)
      @vouchers = @user.vouchers.order("updated_at desc").paginate(:page => params[:page], :per_page => 10)
      render :json => {:success => true, :vouchers => jsonify_vouchers(@vouchers, :version => 2), :total_pages => @vouchers.total_pages, :current_page => @vouchers.current_page }
    else
      render :json => {:success => false, :errors => [t("api.v1.vouchers.received.empty")]}
    end
  end

  def sent_1
    if @user.sent_ious.present?
      @vouchers = @user.sent_ious.paginate(:page => params[:page], :per_page => 10)
      render :json => {:success => true, :vouchers => @vouchers.collect{ |i| jsonify_iou(i) }, :total_pages => @vouchers.total_pages, :current_page => @vouchers.current_page }
    else
      render :json => {:success => false, :errors => [t("api.v1.vouchers.sent.empty")]}
    end
  end

  def redeem_1
    if params[:code].present?
      if current_user.can_redeem_vouchers? or current_user.redeemable_vouchers.present?
        token = params[:code].gsub(/[^A-Za-z0-9]/, "").first(4).upcase
        code = params[:code].gsub(/[^A-Za-z0-9]/, "").last(2).upcase
        vouchers = current_user.redeemable_vouchers
        if vouchers.present?
          if @voucher = vouchers.find{ |v| v.token == token }
            @voucher.redemption_code = code
            if @voucher.iou.expired?
              @json = {:success => false, :errors => [t("vouchers.redeem.error.expired")]}
            elsif @voucher.save and @voucher.reload.redeemed?
              @json = {:success => true, :voucher => jsonify_voucher(@voucher)}
            else
              @json = {:success => false, :errors => [t("vouchers.redeem.error.unredeemable")]}
            end
          else
            @json = {:success => false, :errors => [t("vouchers.redeem.error.not_found")]}
          end
        else
          @json = {:success => false, :errors => [t("vouchers.redeem.error.empty")]}
        end
      else
        @json = {:success => false, :errors => [t("vouchers.redeem.error.permission_denied")]}
      end
    else
      @json = {:success => false, :errors => [t("vouchers.redeem.error.no_code")]}
    end
    render :json => @json
  end

  def recent_1
    if @user.ious.present?
      @ious = Iou.paid.where("sender_id = ? OR recipient_id = ?", @user.id, @user.id).where("status = 'valid' OR status = 'redeemed' OR status = 'expired'").order("created_at DESC").paginate(:page => params[:page], :per_page => 10)
      render :json => {:success => true, :vouchers => @ious.collect{ |i| jsonify_iou(i) }, :total_pages => @ious.total_pages, :current_page => @ious.current_page }
    else
      render :json => {:success => false, :errors => [t("api.v1.vouchers.sent.empty")]}
    end
  end

  def redeemed_2
    if @user.vouchers.present?
      if params[:redeemed_since]
        if (params[:pagination].present? and params[:pagination].to_s == "false")
          @vouchers = @user.vouchers.redeemed.where("redeemed_at >= ?", params[:redeemed_since].to_date)
        else
          @vouchers = @user.vouchers.redeemed.where("redeemed_at >= ?", params[:redeemed_since].to_date).paginate(:page => params[:page], :per_page => 10)
        end
      else
        if (params[:pagination].present? and params[:pagination].to_s == "false")
          @vouchers = @user.vouchers.redeemed
        else
          @vouchers = @user.vouchers.redeemed.paginate(:page => params[:page], :per_page => 10)
        end
      end
      render :json => {:success => true, :vouchers => (params[:only_ids].present? and params[:only_ids].to_s == "true") ? @vouchers.collect { |v| v.id } : jsonify_vouchers(@vouchers, :version => 2) }.merge((params[:pagination].present? and params[:pagination].to_s == "false") ? {} : {:total_pages => @vouchers.total_pages, :current_page => @vouchers.current_page})
    else
      render :json => {:success => false, :errors => [t("api.v1.vouchers.received.empty")]}
    end
  end

private

  def jsonify_voucher(v, options={})
    if options[:version] == 2
      { :id => v.id,
        :status => v.redeemed ? t("api.v1.vouchers.statuses.redeemed") : v.iou.status,
        :person => {
          :id => v.iou.sender_id,
          :name => v.iou.sender_name.present? ? v.iou.sender_name : v.iou.sender.to_s,
          :avatar => v.iou.sender.avatar.file? ? v.iou.sender.avatar(:thumb) : "http://#{current_site.domain}/images/sites/#{current_site.code_name}/users/thumb/missing.png"
        },
        :location => jsonify_location(v.iou.bar),
        :item => {}.merge(v.group_drink.try(:price) ? jsonify_price(v.group_drink.price) : {:name => v.group_drink.try(:price_name), :discounted => v.discounted, :currency => v.total.currency.symbol, :currency_code => v.total.currency.to_s, :cents => v.cents, :discounted_cents => v.discounted_cents, :cents_virtual => v.cents_virtual, :discounted_cents_virtual => v.discounted_cents_virtual, :images => photos_for(v.iou.try(:price))}),
        :date => v.updated_at,
        :message => v.iou.memo
      }.merge((v.redeemed? or v.iou.expired?) ? {} : { :coupon => v.coupon })
    else
      { :status => v.redeemed ? t("api.v1.vouchers.statuses.redeemed") : v.iou.status,
        :person => {
          :id => v.iou.sender_id,
          :name => v.iou.sender_name.present? ? v.iou.sender_name : v.iou.sender.to_s,
          :avatar => v.iou.sender.avatar.file? ? v.iou.sender.avatar(:thumb) : "http://#{current_site.domain}/images/sites/#{current_site.code_name}/users/thumb/missing.png"
        },
        :date => v.updated_at,
        :item_name => v.group_drink.price_name,
        :price => number_to_currency(v.amount.to_f, :unit => v.amount.currency.symbol),
        :location => v.iou.bar_name,
        :city => v.iou.bar.city.name,
        :images => photos_for(v.iou.try(:price)),
        :message => v.iou.memo
      }
    end
  end

  def jsonify_vouchers(vouchers, options={})
    if options[:version] == 2
      vouchers.collect { |v| jsonify_voucher(v, options) }
    else
      vouchers.each do |v|
        base = jsonify_voucher(v, options)
        base.merge!({ :coupon => v.coupon }) unless v.redeemed? or v.iou.expired?
        return base
      end
    end
  end

  def jsonify_iou(iou, options={})
    iou.group_drinks.each do |group_drink|
      base = { :direction => group_drink.iou.sender == current_user ? "sent" : "received",
               :date => group_drink.iou.created_at,
               :item_name => group_drink.price_name,
               :price => number_to_currency(group_drink.amount.to_f, :unit => group_drink.amount.currency.symbol),
               :quantity => group_drink.quantity,
               :location => group_drink.iou.bar_name,
               :city => group_drink.iou.bar.city.name,
               :images => photos_for(group_drink.try(:price)),
               :message => group_drink.iou.memo }
      if group_drink.iou.sender == current_user
        base.merge!({:person => {
                 :id => group_drink.recipient_id,
                 :email => group_drink.recipient_email,
                 :phone_number => group_drink.recipient_phone,
                 :facebook_uid => group_drink.recipient_facebook_uid,
                 :name => group_drink.recipient_name.present? ? group_drink.recipient_name : group_drink.recipient.present? ? group_drink.recipient.to_s : group_drink.recipient_email.present? ? group_drink.recipient_email.split("@").first : group_drink.recipient_phone.present? ? group_drink.recipient_phone : I18n.t("global.generif_friend"),
                 :avatar => (group_drink.recipient and group_drink.recipient.avatar.file?) ? group_drink.recipient.avatar(:thumb) : "http://#{current_site.domain}/images/sites/#{current_site.code_name}/users/thumb/missing.png"}})
      else
        base.merge!({:person => {
                 :id => group_drink.iou.sender_id,
                 :name => group_drink.iou.sender_name.present? ? group_drink.iou.sender_name : group_drink.iou.sender.to_s,
                 :avatar => (group_drink.iou.sender and group_drink.iou.sender.avatar.file?) ? group_drink.iou.sender.avatar(:thumb) : "http://#{current_site.domain}/images/sites/#{current_site.code_name}/users/thumb/missing.png"}})
      end
      return base
    end
  end

end
