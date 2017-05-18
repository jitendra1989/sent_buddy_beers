# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20141015141503) do

  create_table "bar_sites", :force => true do |t|
    t.integer  "bar_id"
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bar_translations", :force => true do |t|
    t.integer  "bar_id"
    t.string   "locale"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bar_translations", ["bar_id", "locale"], :name => "index_bar_translations_on_bar_id_and_locale", :unique => true

  create_table "bars", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.integer  "affiliate_id"
    t.string   "token"
    t.string   "default_currency",                        :limit => 3,                                 :default => "USD"
    t.decimal  "lat",                                                  :precision => 15, :scale => 10
    t.decimal  "lng",                                                  :precision => 15, :scale => 10
    t.string   "phone_number"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "percent_cut",                                                                          :default => 30
    t.integer  "percent_expired_cut",                                                                  :default => 100
    t.boolean  "active",                                                                               :default => false
    t.integer  "country_id"
    t.integer  "city_id"
    t.string   "contact_name"
    t.string   "lead"
    t.string   "contact_email"
    t.string   "url"
    t.integer  "customer_voucher_limit",                                                               :default => 0,        :null => false
    t.boolean  "internet_enabled"
    t.integer  "bro_id"
    t.integer  "outstanding_ious_count",                                                               :default => 0,        :null => false
    t.boolean  "pending",                                                                              :default => true,     :null => false
    t.text     "opening_hours"
    t.string   "cached_slug"
    t.string   "twitter_handle"
    t.text     "mailing_address"
    t.string   "contact_time"
    t.text     "signup_notes"
    t.string   "contact_phone_number"
    t.string   "slug_de"
    t.string   "slug_en"
    t.string   "slug_nl"
    t.string   "slug_th"
    t.boolean  "new_voucher_list_notification",                                                        :default => false,    :null => false
    t.string   "redeemed_voucher_notification_timeframe",                                              :default => "weekly", :null => false
    t.string   "slug_fr"
    t.string   "slug_it"
    t.string   "alternative_phone"
    t.string   "mon_opening_time"
    t.string   "mon_closing_time"
    t.string   "tue_opening_time"
    t.string   "tue_closing_time"
    t.string   "wed_opening_time"
    t.string   "wed_closing_time"
    t.string   "thu_opening_time"
    t.string   "thu_closing_time"
    t.string   "fri_opening_time"
    t.string   "fri_closing_time"
    t.string   "sat_opening_time"
    t.string   "sat_closing_time"
    t.string   "sun_opening_time"
    t.string   "sun_closing_time"
    t.string   "facebook_handle"
  end

  add_index "bars", ["address"], :name => "index_bars_on_address"
  add_index "bars", ["affiliate_id"], :name => "index_bars_on_affiliate_id"
  add_index "bars", ["cached_slug"], :name => "index_bars_on_cached_slug", :unique => true
  add_index "bars", ["city_id"], :name => "index_bars_on_city_id"
  add_index "bars", ["country_id"], :name => "index_bars_on_country_id"
  add_index "bars", ["name"], :name => "index_bars_on_name"
  add_index "bars", ["pending"], :name => "index_bars_on_pending"
  add_index "bars", ["redeemed_voucher_notification_timeframe"], :name => "index_bars_on_redeemed_voucher_notification_timeframe"
  add_index "bars", ["slug_de"], :name => "index_bars_on_slug_de"
  add_index "bars", ["slug_en"], :name => "index_bars_on_slug_en"
  add_index "bars", ["slug_fr"], :name => "index_bars_on_slug_fr"
  add_index "bars", ["slug_it"], :name => "index_bars_on_slug_it"
  add_index "bars", ["slug_nl"], :name => "index_bars_on_slug_nl"
  add_index "bars", ["slug_th"], :name => "index_bars_on_slug_th"

  create_table "beers", :force => true do |t|
    t.string   "name"
    t.integer  "brand_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "beers", ["brand_id"], :name => "index_beers_on_brand_id"
  add_index "beers", ["name"], :name => "index_beers_on_name"

  create_table "beverages", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "beverages", ["name"], :name => "index_beverages_on_name"

  create_table "brands", :force => true do |t|
    t.string   "name"
    t.integer  "beverage_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "brands", ["beverage_id"], :name => "index_brands_on_beverage_id"
  add_index "brands", ["name"], :name => "index_brands_on_name"

  create_table "buddy_emails", :force => true do |t|
    t.string   "email"
    t.integer  "emailable_id"
    t.string   "emailable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "buddy_groups", :force => true do |t|
    t.string   "name"
    t.integer  "groupable_id"
    t.string   "groupable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "buddy_ups", :force => true do |t|
    t.string   "person_name"
    t.string   "place_name"
    t.string   "thing_name"
    t.text     "reason"
    t.string   "facebook_id"
    t.integer  "comments_count"
    t.integer  "likes_count"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "buddy_ups", ["facebook_id"], :name => "index_buddy_ups_on_facebook_id"
  add_index "buddy_ups", ["user_id"], :name => "index_buddy_ups_on_user_id"

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cities", ["country_id"], :name => "index_cities_on_country_id"
  add_index "cities", ["name"], :name => "index_cities_on_name"

  create_table "comments", :force => true do |t|
    t.text     "text"
    t.string   "facebook_id"
    t.integer  "buddy_up_id"
    t.integer  "likes_count"
    t.integer  "user_id"
    t.string   "user_name"
    t.string   "user_facebook_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["buddy_up_id"], :name => "index_comments_on_buddy_up_id"
  add_index "comments", ["facebook_id"], :name => "index_comments_on_facebook_id"
  add_index "comments", ["user_facebook_id"], :name => "index_comments_on_user_facebook_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "corporates", :force => true do |t|
    t.string   "email",                                    :default => "", :null => false
    t.string   "encrypted_password",        :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                            :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "company_name"
    t.string   "no_of_employees"
    t.string   "phone_number"
    t.string   "company_logo"
    t.datetime "confirmed_at"
    t.string   "confirmation_token"
    t.datetime "confirmation_sent_at"
    t.string   "company_logo_file_name"
    t.string   "company_logo_content_type"
    t.integer  "company_logo_file_size"
    t.datetime "company_logo_updated_at"
    t.string   "password_salt"
  end

  add_index "corporates", ["confirmation_token"], :name => "index_corporates_on_confirmation_token", :unique => true
  add_index "corporates", ["email"], :name => "index_corporates_on_email", :unique => true
  add_index "corporates", ["reset_password_token"], :name => "index_corporates_on_reset_password_token", :unique => true

  create_table "countries", :force => true do |t|
    t.string   "iso"
    t.string   "name"
    t.string   "printable_name"
    t.string   "iso3"
    t.integer  "numcode"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "dialing_prefix"
  end

  add_index "countries", ["iso"], :name => "index_countries_on_iso"
  add_index "countries", ["printable_name"], :name => "index_countries_on_printable_name"

  create_table "credit_events", :force => true do |t|
    t.integer  "user_id"
    t.string   "pegged_currency_amount_iso_currency_code"
    t.string   "premium_currency_amount"
    t.string   "offer_id"
    t.string   "socialgold_transaction_id"
    t.string   "net_payout_amount"
    t.string   "cc_token"
    t.string   "billing_country_code"
    t.boolean  "simulated",                                :default => false,          :null => false
    t.string   "pegged_currency_amount"
    t.string   "offer_amount"
    t.string   "socialgold_transaction_status"
    t.string   "amount"
    t.string   "pegged_currency_label"
    t.string   "version"
    t.string   "premium_currency_label"
    t.string   "offer_amount_iso_currency_code"
    t.string   "billing_zip"
    t.string   "user_balance"
    t.string   "event_type"
    t.string   "external_ref_id"
    t.string   "timestamp"
    t.string   "signature"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.boolean  "no_lib",                                   :default => true,           :null => false
    t.string   "provider",                                 :default => "Ultimate Pay", :null => false
    t.integer  "site_id"
    t.string   "commtype"
    t.string   "currency"
    t.string   "detail"
    t.string   "gwtid"
    t.string   "livemode"
    t.string   "login"
    t.string   "mirror"
    t.string   "payment_id"
    t.string   "pbctrans"
    t.string   "rescode"
    t.string   "sepamount"
    t.string   "set_amount"
    t.string   "virtualamount"
    t.string   "sn"
    t.string   "status_message"
    t.integer  "iou_id"
  end

  add_index "credit_events", ["iou_id"], :name => "index_credit_events_on_iou_id"
  add_index "credit_events", ["pbctrans"], :name => "index_credit_events_on_pbctrans"
  add_index "credit_events", ["token"], :name => "index_credit_events_on_token"
  add_index "credit_events", ["user_id"], :name => "index_credit_events_on_user_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "drink_types", :force => true do |t|
    t.integer  "beverage_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "drink_types", ["beverage_id"], :name => "index_drink_types_on_beverage_id"

  create_table "email_invitations", :force => true do |t|
    t.string   "email"
    t.datetime "delivered_at"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_invitations", ["user_id"], :name => "index_email_invitations_on_user_id"

  create_table "emails", :force => true do |t|
    t.integer  "user_id"
    t.string   "email",                         :null => false
    t.boolean  "primary",    :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "pending",    :default => true,  :null => false
    t.string   "token"
    t.boolean  "notified",   :default => false, :null => false
  end

  add_index "emails", ["email"], :name => "index_emails_on_email"
  add_index "emails", ["token"], :name => "index_emails_on_token"
  add_index "emails", ["user_id"], :name => "index_emails_on_user_id"

  create_table "employments", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.integer  "bar_id",                        :null => false
    t.boolean  "active",     :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "employments", ["bar_id"], :name => "index_employments_on_bar_id"
  add_index "employments", ["user_id"], :name => "index_employments_on_user_id"

  create_table "events", :force => true do |t|
    t.string   "title"
    t.string   "event_type"
    t.datetime "day_of_the_event"
    t.integer  "user_id"
    t.string   "friend_fb_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "facebook_app_credentials", :force => true do |t|
    t.string   "access_token"
    t.string   "app_id"
    t.integer  "user_id"
    t.integer  "site_id"
    t.text     "permissions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "facebook_app_credentials", ["app_id"], :name => "index_facebook_app_credentials_on_app_id"
  add_index "facebook_app_credentials", ["site_id"], :name => "index_facebook_app_credentials_on_site_id"
  add_index "facebook_app_credentials", ["user_id"], :name => "index_facebook_app_credentials_on_user_id"

  create_table "facebook_requests", :force => true do |t|
    t.integer  "sender_id",       :limit => 8
    t.integer  "recipient_id",    :limit => 8
    t.integer  "iou_id",          :limit => 8
    t.integer  "facebook_ref_id", :limit => 8
    t.boolean  "open",                         :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_drink_id"
  end

  add_index "facebook_requests", ["facebook_ref_id"], :name => "index_facebook_requests_on_facebook_ref_id"
  add_index "facebook_requests", ["iou_id"], :name => "index_facebook_requests_on_iou_id"
  add_index "facebook_requests", ["recipient_id"], :name => "index_facebook_requests_on_recipient_id"
  add_index "facebook_requests", ["sender_id"], :name => "index_facebook_requests_on_sender_id"

  create_table "friendships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendships", ["friend_id"], :name => "index_friendships_on_friend_id"
  add_index "friendships", ["user_id"], :name => "index_friendships_on_user_id"

  create_table "galleries", :force => true do |t|
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "galleries", ["attachable_id"], :name => "index_galleries_on_attachable_id"
  add_index "galleries", ["attachable_type"], :name => "index_galleries_on_attachable_type"

  create_table "group_drinks", :force => true do |t|
    t.integer  "recipient_id"
    t.string   "recipient_name"
    t.string   "recipient_email"
    t.string   "recipient_phone"
    t.integer  "quantity"
    t.integer  "price_id"
    t.string   "special_message"
    t.integer  "iou_id"
    t.integer  "beverage_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "beer_id"
    t.integer  "cents"
    t.integer  "discounted_cents",                   :default => 0,      :null => false
    t.string   "discounted",                         :default => "f",    :null => false
    t.string   "currency",                           :default => "USD"
    t.string   "price_name"
    t.string   "beverage_name"
    t.string   "beer_name"
    t.integer  "brand_id"
    t.string   "recipient_facebook_uid"
    t.string   "brand_name"
    t.datetime "expires_at"
    t.boolean  "paid",                               :default => false,  :null => false
    t.boolean  "notified",                           :default => false,  :null => false
    t.string   "status",                             :default => "sent", :null => false
    t.string   "token"
    t.integer  "order_id"
    t.boolean  "promotional",                        :default => false,  :null => false
    t.boolean  "company_promotional",                :default => false,  :null => false
    t.datetime "paid_at"
    t.datetime "sms_notified_at"
    t.datetime "posted_to_facebook_wall_at"
    t.datetime "posted_to_friends_facebook_wall_at"
    t.datetime "sent_facebook_message_at"
  end

  create_table "ious", :force => true do |t|
    t.integer  "recipient_id"
    t.string   "recipient_name"
    t.integer  "sender_id"
    t.string   "sender_name"
    t.integer  "beverage_id"
    t.integer  "brand_id"
    t.integer  "beer_id"
    t.integer  "bar_id"
    t.string   "status",                             :default => "sent", :null => false
    t.string   "token"
    t.integer  "order_id"
    t.text     "memo"
    t.integer  "quantity"
    t.boolean  "paid",                               :default => false,  :null => false
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "recipient_email"
    t.boolean  "notified",                           :default => false,  :null => false
    t.integer  "cents",                              :default => 0,      :null => false
    t.boolean  "expired",                            :default => false,  :null => false
    t.boolean  "promotional",                        :default => false,  :null => false
    t.string   "brand_name"
    t.string   "beer_name"
    t.string   "bar_name"
    t.string   "beverage_name"
    t.integer  "price_id"
    t.string   "currency",                           :default => "USD",  :null => false
    t.integer  "discounted_cents",                   :default => 0,      :null => false
    t.boolean  "discounted",                         :default => false,  :null => false
    t.integer  "site_id"
    t.boolean  "company_promotional",                :default => false,  :null => false
    t.datetime "paid_at"
    t.string   "recipient_phone"
    t.datetime "sms_notified_at"
    t.string   "price_name"
    t.string   "recipient_facebook_uid"
    t.boolean  "public",                             :default => true,   :null => false
    t.integer  "lock_version",                       :default => 0,      :null => false
    t.datetime "posted_to_facebook_wall_at"
    t.datetime "posted_to_friends_facebook_wall_at"
    t.datetime "sent_facebook_message_at"
  end

  add_index "ious", ["bar_id"], :name => "index_ious_on_bar_id"
  add_index "ious", ["beer_id"], :name => "index_ious_on_beer_id"
  add_index "ious", ["beverage_id"], :name => "index_ious_on_beverage_id"
  add_index "ious", ["brand_id"], :name => "index_ious_on_brand_id"
  add_index "ious", ["order_id"], :name => "index_ious_on_order_id"
  add_index "ious", ["price_id"], :name => "index_ious_on_price_id"
  add_index "ious", ["promotional"], :name => "index_ious_on_promotional"
  add_index "ious", ["public"], :name => "index_ious_on_public"
  add_index "ious", ["recipient_email"], :name => "index_ious_on_recipient_email"
  add_index "ious", ["recipient_id"], :name => "index_ious_on_recipient_id"
  add_index "ious", ["recipient_phone"], :name => "index_ious_on_recipient_phone"
  add_index "ious", ["sender_id"], :name => "index_ious_on_sender_id"
  add_index "ious", ["site_id"], :name => "index_ious_on_site_id"
  add_index "ious", ["status"], :name => "index_ious_on_status"
  add_index "ious", ["token"], :name => "index_ious_on_token"

  create_table "karma_points", :force => true do |t|
    t.integer  "value"
    t.integer  "user_id"
    t.integer  "pointable_id"
    t.string   "pointable_type"
    t.boolean  "like",           :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "karma_points", ["pointable_type", "pointable_id"], :name => "index_karma_points_on_pointable_type_and_pointable_id"

  create_table "line_items", :force => true do |t|
    t.integer  "payment_id"
    t.integer  "bar_id"
    t.integer  "iou_id"
    t.integer  "voucher_id"
    t.string   "payout_percent"
    t.string   "status"
    t.integer  "cents"
    t.string   "currency"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "line_items", ["bar_id"], :name => "index_line_items_on_bar_id"
  add_index "line_items", ["created_at"], :name => "index_line_items_on_created_at"
  add_index "line_items", ["iou_id"], :name => "index_line_items_on_iou_id"
  add_index "line_items", ["payment_id"], :name => "index_line_items_on_payment_id"
  add_index "line_items", ["status"], :name => "index_line_items_on_status"
  add_index "line_items", ["voucher_id"], :name => "index_line_items_on_voucher_id"

  create_table "metrics", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.integer  "user_id"
    t.datetime "achieved_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "metrics", ["achieved_at"], :name => "index_metrics_on_achieved_at"
  add_index "metrics", ["name"], :name => "index_metrics_on_name"
  add_index "metrics", ["user_id"], :name => "index_metrics_on_user_id"
  add_index "metrics", ["value"], :name => "index_metrics_on_value"

  create_table "page_translations", :force => true do |t|
    t.integer  "page_id"
    t.string   "locale"
    t.string   "title"
    t.text     "body"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "page_translations", ["page_id", "locale", "slug"], :name => "index_page_translations_on_page_id_and_locale_and_slug", :unique => true

  create_table "pages", :force => true do |t|
    t.boolean  "navigation", :default => false, :null => false
    t.boolean  "published",  :default => false, :null => false
    t.boolean  "footer",     :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.integer  "position",   :default => 0
  end

  add_index "pages", ["footer"], :name => "index_pages_on_footer"
  add_index "pages", ["navigation"], :name => "index_pages_on_navigation"
  add_index "pages", ["parent_id"], :name => "index_pages_on_parent_id"
  add_index "pages", ["position"], :name => "index_pages_on_position"
  add_index "pages", ["published"], :name => "index_pages_on_published"

  create_table "pages_sites", :id => false, :force => true do |t|
    t.integer "page_id"
    t.integer "site_id"
  end

  add_index "pages_sites", ["page_id"], :name => "index_pages_sites_on_page_id"
  add_index "pages_sites", ["site_id"], :name => "index_pages_sites_on_site_id"

  create_table "paid_voucher_details", :force => true do |t|
    t.integer  "no_of_redeemed_vouchers"
    t.integer  "affiliate_id"
    t.datetime "date"
    t.string   "mode"
    t.string   "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "paid_vouchers", :force => true do |t|
    t.integer  "voucher_id"
    t.datetime "paid_at"
    t.boolean  "is_paid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", :force => true do |t|
    t.integer  "affiliate_id"
    t.string   "affiliate_name"
    t.boolean  "paid",           :default => false, :null => false
    t.integer  "cents",          :default => 0,     :null => false
    t.datetime "beginning_at",                      :null => false
    t.datetime "ending_at",                         :null => false
    t.datetime "paid_at"
    t.string   "currency"
    t.text     "notes"
    t.text     "admin_notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payments", ["affiliate_id"], :name => "index_payments_on_affiliate_id"
  add_index "payments", ["paid"], :name => "index_payments_on_paid"

  create_table "payout_models", :force => true do |t|
    t.integer  "bar_id",                            :null => false
    t.integer  "low_cents",      :default => 0,     :null => false
    t.integer  "high_cents"
    t.string   "currency",       :default => "USD", :null => false
    t.integer  "percent_payout",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payout_models", ["bar_id"], :name => "index_payout_models_on_bar_id"
  add_index "payout_models", ["high_cents"], :name => "index_payout_models_on_high_cents"
  add_index "payout_models", ["low_cents"], :name => "index_payout_models_on_low_cents"

  create_table "payouts", :force => true do |t|
    t.integer  "affiliate_id"
    t.string   "name"
    t.string   "email"
    t.string   "address"
    t.string   "payment_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", :force => true do |t|
    t.integer  "gallery_id"
    t.string   "title"
    t.text     "description"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.string   "photo_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "prices", :force => true do |t|
    t.integer  "beer_id"
    t.integer  "bar_id"
    t.integer  "cents"
    t.string   "currency",           :default => "USD"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "discounted_cents",   :default => 0,     :null => false
    t.boolean  "discounted",         :default => false, :null => false
    t.string   "name"
    t.text     "description"
    t.string   "volume"
    t.integer  "drink_type_id"
    t.integer  "beverage_id"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.string   "photo_file_size"
  end

  add_index "prices", ["beer_id"], :name => "index_prices_on_beer_id"
  add_index "prices", ["drink_type_id"], :name => "index_prices_on_drink_type_id"

  create_table "qr_images", :force => true do |t|
    t.string   "md5",                       :null => false
    t.string   "ecc"
    t.integer  "version",    :default => 6
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_admin_sites", :force => true do |t|
    t.integer  "site_id"
    t.integer  "site_admin_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.string   "subdomain"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code_name"
    t.string   "facebook_app_id"
    t.string   "facebook_app_secret"
    t.string   "domain"
    t.string   "facebook_app_url"
    t.text     "facebook_app_scope"
  end

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

  create_table "sms_invitations", :force => true do |t|
    t.string   "phone_number"
    t.string   "phone_number_country_code"
    t.datetime "sms_delivered_at"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sms_invitations", ["user_id"], :name => "index_sms_invitations_on_user_id"

  create_table "subcriptions", :force => true do |t|
    t.integer  "payer_id"
    t.string   "payer_name"
    t.string   "paypal_payer_id"
    t.string   "paypal_token"
    t.string   "quantity"
    t.float    "amount"
    t.string   "currency"
    t.string   "iou_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tolk_locales", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tolk_locales", ["name"], :name => "index_tolk_locales_on_name", :unique => true

  create_table "tolk_phrases", :force => true do |t|
    t.text     "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tolk_translations", :force => true do |t|
    t.integer  "phrase_id"
    t.integer  "locale_id"
    t.text     "text"
    t.text     "previous_text"
    t.boolean  "primary_updated", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tolk_translations", ["phrase_id", "locale_id"], :name => "index_tolk_translations_on_phrase_id_and_locale_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "login"
    t.string   "sex"
    t.string   "type"
    t.string   "encrypted_password"
    t.string   "password_salt"
    t.integer  "sign_in_count",                        :default => 0
    t.integer  "failed_login_count",                   :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email_hash",             :limit => 64
    t.integer  "facebook_uid",           :limit => 8
    t.string   "facebook_session_key"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.string   "language",               :limit => 5,  :default => "en",  :null => false
    t.string   "phone_number",           :limit => 32
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "credits",                              :default => "0",   :null => false
    t.string   "default_currency",                     :default => "USD", :null => false
    t.string   "paypal_email"
    t.string   "bank_account_name"
    t.string   "bank_account_number"
    t.string   "bank_account_bank_code"
    t.string   "bank_name"
    t.text     "bank_address"
    t.string   "bank_account_iban"
    t.string   "bank_account_bic_swift"
    t.string   "promotion_group"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_up_site_id"
    t.datetime "reset_password_sent_at"
    t.string   "authentication_token"
    t.text     "facebook_permissions"
    t.integer  "karma",                                :default => 0,     :null => false
    t.datetime "birthday_day"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["facebook_uid"], :name => "index_users_on_facebook_uid"
  add_index "users", ["login"], :name => "index_users_on_twitter_handle"
  add_index "users", ["name"], :name => "index_users_on_name"
  add_index "users", ["oauth_token"], :name => "index_users_on_oauth_token"
  add_index "users", ["promotion_group"], :name => "index_users_on_promotion_group"
  add_index "users", ["sign_up_site_id"], :name => "index_users_on_sign_up_site_id"

  create_table "voucher_lists", :force => true do |t|
    t.integer  "bar_id",                        :null => false
    t.integer  "cents",                         :null => false
    t.string   "currency",   :default => "USD", :null => false
    t.boolean  "closed",     :default => false, :null => false
    t.boolean  "archived",   :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "downloaded", :default => false, :null => false
  end

  create_table "vouchers", :force => true do |t|
    t.integer  "voucher_list_id",                     :null => false
    t.string   "token",                               :null => false
    t.string   "redemption_token",                    :null => false
    t.integer  "bar_id",                              :null => false
    t.integer  "iou_id"
    t.boolean  "redeemed",         :default => false, :null => false
    t.integer  "cents",                               :null => false
    t.string   "currency",         :default => "USD", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "redeemed_at"
    t.integer  "discounted_cents", :default => 0,     :null => false
    t.boolean  "discounted",       :default => false, :null => false
    t.integer  "group_drink_id"
  end

  add_index "vouchers", ["bar_id"], :name => "index_vouchers_on_bar_id"
  add_index "vouchers", ["redeemed", "bar_id"], :name => "index_vouchers_on_redeemed_and_bar_id"
  add_index "vouchers", ["voucher_list_id"], :name => "index_vouchers_on_voucher_list_id"

end
