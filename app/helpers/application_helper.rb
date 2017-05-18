# -*- coding: utf-8 -*-
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def namespace_for(object)
    object.class.name.underscore
  end

  def stylesheets(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end

  def javascripts(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end

  def clear_floats
    content_tag(:div, "<!-- Clearing Floats -->".html_safe, :class => "clear")
  end

  def setup_user(user)
    user.tap do |u|
      u.emails.build if u.emails.empty?
    end
  end

  def hint_box(id, title, description)
    html = "<a class=\"hint\" href=\"##{id}\">#{image_tag "sites/default/buttons/question.png", :alt => ""}</a>"
    html += "<div style=\"display: none\" >"
    html += "<div id=\"#{id}\" class=\"hint_box\"><div class=\"header\">"
    html += "<h3><span class=\"color\">#{title}</span></h3>"
    html += "</div><div class=\"description\">"
    html += "<p>#{description}</p></div></div></div>"
    html.html_safe
  end

  def currencies_in_use
    ["USD", "EUR", "GBP", "CAD", "CHF", "THB"]
  end

  def currency_symbol_for(currency, html=true)
    case currency
    when "EUR"
      html ? "&euro;" : "€"
    when "USD"
      html ? "&#36;" : "$"
    when "GBP"
      html ? "&pound;" : "£"
    when "CAD"
      html ? "C&#36;" : "C$"
    when "CHF"
      "Fr"
    when "THB"
      html ? "&#3647;" : "฿"
    end
  end

  def country_code_for(locale)
    case locale
    when :en
      "US"
    when :de
      "DE"
    when:nl
      "NL"
    end
  end

  def dialing_codes
    @codes =  [
                [ t("ious.form.form.buddy_beers_countries"),
                  Country.with_active_bars.with_bars_for_site(current_site).uniq.collect{ |c| ["#{t("countries.#{c.printable_name.parameterize.gsub("-", "_")}")} (+#{c.dialing_prefix})", c.dialing_prefix]}.sort{|a, b| b[0] <=> a[0]}
                ],
                [ t("ious.form.form.other_countries"),
                  Country.all.collect{ |c| ["#{t("countries.#{c.printable_name.parameterize.gsub("-", "_")}")} (+#{c.dialing_prefix})", c.dialing_prefix]}.sort{|a, b| a[0] <=> b[0]}
                ]
              ]
  end

  def countries_for_select
    @codes =  [
                [ t("ious.form.form.buddy_beers_countries"),
                  Country.with_active_bars.with_bars_for_site(current_site).uniq.collect{ |c| ["#{t("countries.#{c.printable_name.parameterize.gsub("-", "_")}")}", c.id]}.sort{|a, b| b[0] <=> a[0]}
                ],
                [ t("ious.form.form.other_countries"),
                  Country.all.collect{ |c| ["#{t("countries.#{c.printable_name.parameterize.gsub("-", "_")}")}", c.id]}.sort{|a, b| a[0] <=> b[0]}
                ]
              ]
  end

  def other_locales
    I18n.available_locales.delete_if{|l| l == I18n.locale}
  end

  def conjunctions
    [t("global.conjunctions.and"), t("global.conjunctions.now"), t("global.conjunctions.but"), t("global.conjunctions.so"), t("global.conjunctions.only"), t("global.conjunctions.therefore"), t("global.conjunctions.moreover"), t("global.conjunctions.besides"), t("global.conjunctions.consequently"), t("global.conjunctions.nevertheless"), t("global.conjunctions.for"), t("global.conjunctions.however"), t("global.conjunctions.hence"), t("global.conjunctions.while"), t("global.conjunctions.then"), t("global.conjunctions.who"), t("global.conjunctions.wich"), t("global.conjunctions.that"), t("global.conjunctions.although"), t("global.conjunctions.though"), t("global.conjunctions.while"), t("global.conjunctions.since"), t("global.conjunctions.until"), t("global.conjunctions.as"), t("global.conjunctions.after"), t("global.conjunctions.before"), t("global.conjunctions.how"), t("global.conjunctions.once"), t("global.conjunctions.when"), t("global.conjunctions.lest"), t("global.conjunctions.if"), t("global.conjunctions.in_order"), t("global.conjunctions.unless"), t("global.conjunctions.whether"), t("global.conjunctions.because"), t("global.conjunctions.till"), t("global.conjunctions.where"), t("global.conjunctions.whether")]
  end

  def pageless(total_pages, url=nil, container=nil, message="Loading")
    opts = {
      :totalPages => total_pages,
      :url        => url,
      :loaderHtml  => "<div class=\"loader\">#{message}<br />#{image_tag('sites/default/graphics/ajax-loader.gif')}</div>",
      :distance => 500
    }

    container && opts[:container] ||= container

    javascript_tag("$('#{container}').pageless(#{opts.to_json});")
  end

  def user_profile_image_com(object)
    (!object.sender.blank? && object.sender.facebook_user? && !object.sender.avatar.file?) ? "http://graph.facebook.com/#{object.sender.facebook_uid}/picture?type=square" : "/images/default-photo.png"
  end

  def sender_name(object)
    object.sender_name.blank? ? object.sender.login : object.sender_name
  end

  def recipient_name(object)
    object.recipient_name.blank? ? t(".default_friend") : object.recipient_name
  end

  # Admin Dashboard action

  def today_buddybucks_count
    date = today_date
    CreditEvent.find_buy_buddybucks_with_created_at(DateTime.now.beginning_of_day, DateTime.now.end_of_day).count
  end

  def this_week_buddybucks_count
    date = today_date
    CreditEvent.find_buy_buddybucks_with_created_at(date.beginning_of_week, date.end_of_week).count
  end

  def this_month_buddybucks_count
    date = today_date
    CreditEvent.find_buy_buddybucks_with_created_at(date.beginning_of_month, date.end_of_month).count
    #CreditEvent.find_buy_buddybucks_with_created_at((DateTime.now - 3.years).beginning_of_year.to_date, (DateTime.now - 3.years).end_of_year.to_date).count
  end

  def today_buddybucks_revenue
    buddybucks_obj = CreditEvent.find_buy_buddybucks_with_created_at(DateTime.now.beginning_of_day, DateTime.now.end_of_day)
    calculate_revenue_amount(buddybucks_obj)
  end

  def this_week_buddybucks_revenue
    date = today_date
    buddybucks_obj = CreditEvent.find_buy_buddybucks_with_created_at(date.beginning_of_week, date.end_of_week)
    calculate_revenue_amount(buddybucks_obj)
  end

  def this_month_buddybucks_revenue
    date = today_date
    buddybucks_obj = CreditEvent.find_buy_buddybucks_with_created_at(date.beginning_of_month, date.end_of_month)
    calculate_revenue_amount(buddybucks_obj)
  end

  def total_buddybucks_revenue
    CreditEvent.buy_buddybucks.map{ |bb| bb.sepamount.to_f}.sum rescue ""
  end

  def calculate_revenue_amount(buddybucks_obj)
    buddybucks_obj.map{ |bb| bb.sepamount.to_f}.sum rescue ""
  end

  def today_users_count
    date = today_date
    User.find_user_with_created_at(DateTime.now.beginning_of_day, DateTime.now.end_of_day).count
  end

  def this_week_users_count
    date = today_date
    User.find_user_with_created_at(date.beginning_of_week, date.end_of_week).count
  end

  def this_month_users_count
    date = today_date
    User.find_user_with_created_at(date.beginning_of_month, date.end_of_month).count
  end

  def total_users
    users = User.get_users
    users.count
  end


  def today_corporates_count
    date = today_date
    #Affiliate.find_corporates_with_created_at(date.beginning_of_day, date.end_of_day).count
    0
  end

  def this_week_corporates_count
    date = today_date
    #Affiliate.find_corporates_with_created_at(date.beginning_of_week, date.end_of_week).count
    0
  end

  def this_month_corporates_count
    date = today_date
    #Affiliate.find_corporates_with_created_at(date.beginning_of_month, date.end_of_month).count
    0
  end

  def total_corporates
    0
  end

  def today_venues_count
    date = today_date
    Bar.find_venue_with_created_at(DateTime.now.beginning_of_day, DateTime.now.end_of_day).count
  end

  def this_week_venues_count
    date = today_date
    Bar.find_venue_with_created_at(date.beginning_of_week, date.end_of_week).count
  end

  def this_month_venues_count
    date = today_date
    Bar.find_venue_with_created_at(date.beginning_of_month, date.end_of_month).count
  end

  def total_venues
    venues = Bar.get_venues
    venues.count
  end

  def today_sent_drinks_count
    date = today_date
    GroupDrink.find_set_drinks_with_created_at(date.beginning_of_day, date.end_of_day).sum(:quantity)
  end

  def this_week_sent_drinks_count
    date = today_date
    GroupDrink.find_set_drinks_with_created_at(date.beginning_of_week, date.end_of_week).sum(:quantity)
  end

  def this_month_sent_drinks_count
    date = today_date
    GroupDrink.find_set_drinks_with_created_at(date.beginning_of_month, date.end_of_month).sum(:quantity)
  end

  def today_sent_drinks_revenue
    date = today_date
    #Iou.find_set_drinks_with_created_at(date.beginning_of_day, date.end_of_day).sum(:cents)
    gds = GroupDrink.find_set_drinks_with_created_at(date.beginning_of_day, date.end_of_day)
    calculate_revenue(gds)
  end

  def this_week_sent_drinks_revenue
    date = today_date
    #Iou.find_set_drinks_with_created_at(date.beginning_of_week, date.end_of_week).sum(:cents)
    gds = GroupDrink.find_set_drinks_with_created_at(date.beginning_of_week, date.end_of_week)
    calculate_revenue(gds)
  end
  def this_month_sent_drinks_revenue
    date = today_date
    #Iou.find_set_drinks_with_created_at(date.beginning_of_month, date.end_of_month).sum(:cents)
    gds = GroupDrink.find_set_drinks_with_created_at(date.beginning_of_month, date.end_of_month)
    calculate_revenue(gds)
  end

  def today_date
    Date.today
  end
  def calculate_revenue(gds)
    gds.map{|gd| gd.total.to_f}.sum
  end

  def formated_datetime(obj)
    obj.created_at.strftime("%m-%d-%y %r")
  end
  def formated_birthday_date(obj)
    birthdate = obj.birthday_day
    today_date = Date.today
    after_15_day = today_date + 15.days
    if (birthdate.month == 1 && today_date.month == 12)
      dob = birthdate.to_date.change(:year => after_15_day.year)
    else
      dob = birthdate.to_date.change(:year => today_date.year)
    end
    day_difference = (dob - today_date).to_i
    if day_difference > 0
      if day_difference == 1
        "Tomorrow!"
      else
        "in #{day_difference} days"
      end
    else
      365 + day_difference
    end
  end
  def date_for_comming_event(birthdate)
    today_date = Date.today
    after_15_day = today_date + 15.days
    if (today_date.month == 12 && birthdate.month == 1)
      dob = birthdate.to_date.change(:year => after_15_day.year)
    else
      dob = birthdate.to_date.change(:year => today_date.year)
    end
    dob.strftime("%A, %B %d")
  end
  
  def app_button_on_footer
    (request.fullpath == "/apps" ? "pull-right" : "")
  end

  def merchant_payout(merchant_payout_amount)
    (merchant_payout_amount * 70)/100.to_f
  end

  def redeemed_voucher(obj)
    unless obj.redeemed?
      "Not Redeemed yet"
    else
      "Redeemed"
    end
  end

end
