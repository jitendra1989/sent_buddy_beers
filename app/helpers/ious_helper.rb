module IousHelper
  def beverage_owed(iou)
    iou.price_name.present? ? iou.price_name : [iou.brand_name, iou.beer_name].join(" ")
  end

  def status_for(object, simple = false)
    if object.is_a?(Iou)
      case object.status
      when "valid"
        content_tag(:em, simple ? t("ious.show.statuses.simple.valid") : t("ious.show.statuses.valid_until", :date => object.expires_at.to_s(:euro_date)), :class => "status_valid")
      when "redeemed"
         content_tag(:em, simple ? t("ious.show.statuses.simple.redeemed") : t("ious.show.statuses.redeemed"), :class => "status_redeemed")
      when "sent"
         content_tag(:em, simple ? t("ious.show.statuses.simple.sent") : t("ious.show.statuses.sent"), :class => "status_sent")
      when "expired"
         content_tag(:em, simple ? t("ious.show.statuses.simple.expired") : t("ious.show.statuses.expired"), :class => "status_expired")
      end
    elsif object.is_a?(Voucher)
      if object.redeemed
        content_tag(:em, t("ious.show.statuses.redeemed_on", :date => object.redeemed_at.to_s(:euro_date)), :class => "status_redeemed")
      elsif object.iou.expired?
        content_tag(:em, t("ious.show.statuses.expired_on", :date => object.iou.expires_at.to_s(:euro_date)), :class => "status_expired")
      elsif object.redeemable?
        content_tag(:em, t("ious.show.statuses.valid_until", :date => object.iou.expires_at.to_s(:euro_date)), :class => "status_valid")
      else
        content_tag(:em, t("ious.show.statuses.sent_on", :date => object.iou.created_at.to_s(:euro_date)), :class => "status_sent")
      end
    end
  end

  def twitter_name_for(gd)
    if gd.recipient and gd.recipient.login.present?
      gd.recipient.login.gsub(" ", "")
    elsif gd.recipient and gd.recipient.name.present?
      gd.recipient.name.gsub(" ", "")
    elsif gd.recipient_name.present?
      gd.recipient_name.gsub(" ", "")
    else
      t("shared.drink_in_feed.default_friend")
    end
  end

  def twitter_share_link_for(group_drink)
    link_to content_tag(:span, t("ious.confirmed_payment.social_spread.twitter_link")), "http://twitter.com/share?count=none&lang=#{I18n.locale.to_s}&url=false&text=#{t("ious.confirmed_payment.social_spread.twitter_status", :recipient => twitter_name_for(group_drink), :beer => [group_drink.quantity, group_drink.price_name].join(" "), :city => @iou.bar.city.name, :bar => @iou.bar.name)}", :target => "_blank", :id => "twitter_link"
  end

  def order_participant_photo(order, direction, default = "avatars/thumb/missing.png")
    participant = order.sender if direction == "sender"
    participant = order.recipient if direction == "recipient"
    if participant
      if participant.avatar.file?
        participant.avatar(:thumb)
      elsif participant.facebook_user?
        "http://graph.facebook.com/#{participant.facebook_uid}/picture"
      elsif (direction == "recipient") and order.price.photo.file?
        order.price.photo(:thumb)
      else
        default
      end
    elsif (direction == "recipient") and order.recipient_facebook_uid.present?
      "http://graph.facebook.com/#{order.recipient_facebook_uid}/picture"
    elsif (direction == "recipient") and order.price and order.price.photo.file?
      order.price.photo(:thumb)
    else
      default
    end
  end

  def calculate_total(iou)
    iou.group_drinks.map{ |gd| calculate_amount(gd) }.sum
  end

  def calculate_amount(group_drink)
    group_drink.price.total.to_f * group_drink.quantity.to_i
  end

  def calculate_total_bucks(iou)
    iou.group_drinks.map{ |gd| calculate_bucks(gd) }.sum
  end

  def calculate_bucks(group_drink)
    group_drink.price_in_bucks
  end

  def calculate_sent_quantity(ious)
    ious.includes(:group_drinks).map{|gd| gd.quantity}.sum unless ious.blank? && ious.includes(:group_drinks).blank?
  end

  def get_new_qr_code(voucher)
    if !(voucher.redeemed? or voucher.iou.expired?)
      RQRCode::QRCode.new(voucher.coupon, :size => 3, :level => :h )
    end
  end

end
