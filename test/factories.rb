# Minimum attributes required to make this model valid

Factory.sequence :login do |n|
  "foobar#{n}"
end

Factory.define :user do |f|
  f.login { Factory.next(:login) }
  f.password "foobar"
  f.password_confirmation { |u| u.password }
  f.language "en"
  f.emails_attributes { |u| {"0" => {:email => "#{u.login}@example.com"}} }
end

Factory.define :active_user, :parent => :user do |f|
  f.confirmed_at Time.now
end

Factory.define :unconfirmed_customer, :class => "Customer", :parent => :user do |f|
end

Factory.define :customer, :parent => :unconfirmed_customer do |f|
  f.after_create { |u| u.confirm! }
end

Factory.define :bro, :class => "Bro", :parent => :active_user do |f|
  f.phone_number "774445553"
end

Factory.define :affiliate, :class => "Affiliate", :parent => :active_user do |f|
end

Factory.define :admin, :class => "Admin", :parent => :active_user do |f|
end

Factory.define :site_admin, :class => "SiteAdmin", :parent => :active_user do |f|
end

Factory.define :email do |f|
  f.association :user
  f.sequence(:email) { |n| "foo#{n}@example.com" }
  f.pending true
  f.primary false
end

Factory.define :employment do |f|
  f.association :user
  f.association :bar
end

Factory.define :iou do |f|
  f.association :sender, :factory => :customer
  f.association :price
  f.bar { |iou| iou.price.bar }
  f.association :site
  f.status "sent"
  f.quantity 1
  f.recipient_email "foo@example.com"
  f.recipient_phone "49177893342"
  f.notified false
  f.paid false
end

Factory.define :bar do |f|
  f.name "Foo Bar"
  f.address "100 Main St."
  f.association :country
  f.association :city
  f.association :affiliate
  f.active true
  f.sequence(:contact_email) { |n| "foobar#{n}@example.com" }
  f.contact_phone_number "15555555555"
  f.contact_name "Mr. Bar"
  f.percent_cut 70
  f.percent_expired_cut 100
end

Factory.define :beer do |f|
  f.name "Beer"
  f.association :brand
end

Factory.define :brand do |f|
  f.sequence(:name) { |n| "Beer Brand #{n}" }
  f.association :beverage
end

Factory.define :beverage do |f|
  f.sequence(:name) { |n| "beer#{n}" }
end

Factory.define :country do |f|
  f.sequence(:iso) { |n| "DE#{n}" }
  f.sequence(:name) { |n| "GERMANY#{n}" }
  f.printable_name "Germany"
  f.sequence(:iso3) { |n| "DEU#{n}" }
  f.sequence(:numcode) { |n| n }
end

Factory.define :city do |f|
  f.sequence(:name) { |n| "Berlin#{n}" }
  f.association :country
end

Factory.define :price do |f|
  f.cents 200
  f.name "Berliner Pilsner"
  f.association :bar
end

Factory.define :discounted_price, :parent => :price do |f|
  f.discounted true
  f.discounted_cents 50
end

Factory.define :gallery do |f|
end

Factory.define :drink_type do |f|
  f.association :beverage
end

Factory.define :draught, :class => "Draught", :parent => :drink_type do |f|
end

Factory.define :bottle, :class => "Bottle", :parent => :drink_type do |f|
end

Factory.define :photo do |f|
  f.photo { f.paperclip_fixture("photo", "photo", "png") }
end

Factory.define :payment do |f|
  f.association :affiliate
  f.beginning_at 1.month.ago.beginning_of_month
  f.ending_at 1.month.ago.end_of_month
end

Factory.define :voucher_list do |f|
  f.association :bar
  f.cents 200
end

Factory.define :voucher do |f|
  f.association :voucher_list
  f.association :bar
  f.association :iou
  f.cents 200
end

Factory.define :line_item do |f|
  f.association :payment
  f.association :bar
  f.association :iou
  f.association :voucher
  f.cents 200
end

Factory.define :payout_model do |f|
  f.association :bar
  f.percent_payout 30
end

Factory.define :friendship do |f|
  f.user   { |a| a.association(:user) }
  f.friend { |a| a.association(:user) }
end

Factory.define :site do |f|
  f.sequence(:name) { |n| "Site-#{n}" }
  f.domain { |site| "#{site.name.parameterize}.local" }
  f.subdomain { |site| site.name.parameterize }
  f.code_name { |site| site.name.parameterize }
  f.sequence(:facebook_app_id) { |n| "#{n}" }
end

Factory.define :default_site, :parent => :site do |f|
  f.name "BuddyBeers"
  f.domain "test.host"
  f.subdomain nil
  f.code_name "buddybeers"
end

Factory.define :site_admin_site do |f|
  f.association :site_admin
  f.association :site
end

Factory.define :bar_site do |f|
  f.association :bar
  f.association :site
end

Factory.define :credit_event do |f|
end

Factory.define :page do |f|
end

Factory.define :page_translation do |f|
  f.title "This is the English Title"
  f.body "This is the English Body"
  f.locale "en"
  f.association :page
end

Factory.define :page_site do |f|
  f.association :page
  f.association :site
end

Factory.define :email_invitation do |f|
  f.email "email@example.com"
end
