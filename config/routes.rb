Rails.application.routes.draw do

  if Rails.env.test?
    default_url_options :host => "buddybeers.local:3000"
  end

  devise_for :corporates, :controllers => { :registrations => "corporates/registrations", :confirmations => "corporates/confirmations",  :sessions => "corporates/sessions", :passwords => "corporates/passwords"} do
    match "corporates/confirm", :to => "corporates/registrations#confirm", :via => :post
    match "startups_business", :to=> "corporates/registrations#startups_business", :via=>:get
    match "corporates/delete_pic", :to => "corporates/registrations#delete_pic", :via => :get
    match "corporates/buddy_groups", :to => "corporates/home#buddy_groups", :via => :get
    put "corporates/create_groups", :to => "corporates/home#create_groups", :as => :corporates_create_groups
    match "corporates/create_group_email", :to => "corporates/home#create_group_email", :via => :post
    match "corporates/buddy_emails_destroy", :to => "corporates/home#buddy_emails_destroy", :via => :delete
  end

  resources :email_invitations

  filter :locale

  # Omniauth dynamic providers
  match "/users/auth/facebook", :to => "omniauth_setups#facebook"

  devise_for :users, :controllers => {:registrations => "registrations", :confirmations => "confirmations", :sessions => "sessions", :omniauth_callbacks => "omniauth_callbacks"} do
    get "/login" => "devise/sessions#new", :as => :login
    match "users/sign_in_with_email", :to => "sessions#create_with_email", :as => :user_session_with_email, :via => :post
    match "users/sign_up_with_email", :to => "registrations#create_with_email", :as => :user_registration_with_email, :via => :post
    match "users/sign_up_with_facebook", :to => "registrations#create_with_facebook", :as => :user_registration_with_facebook, :via => :post
    match "users/sign_up_complete", :to => "registrations#complete", :via => :get
    match "users/delete_user_pic", :to => "registrations#delete_user_pic", :via => :get
  end

  # Redirect old confirmation url to new one
  get "/register/:activation_code" => redirect("/users/confirmation?confirmation_token=%{activation_code}")

  # Static pages
  get "privacy", :to => "home#privacy"
  get "impressum", :to => "home#impressum"
  get "about", :to => "home#about"
  get "business_perks", :to => "home#business_perks"
  get "white_label_program", :to => "home#white_label_program"
  #get "press", :to => "home#press"
  get "terms", :to => "home#terms"
  get "agb", :to => "home#terms"
  get "iphone", :to => "home#apps"
  get "apps", :to => "home#apps", :as => :app_download
  post "subscribe", :to => "home#subscribe", :as => :subscribe
  post "contact_send", :to=> "home#contact_send"
  post "information_send", :to=> "home#information_send"

  #campaign redirects
  #match "oktoberfest", :to => "bars#show", :id => "schuetzen-festzelt-bavaroi-oktoberfest-11-muenchen-germany"
  match "movember", :to => "bars#show", :id => "belushi-s-berlin-germany", :locale => :en

  match "/emails/activate/:activation_code", :to => "emails#activate", :as => :email_activation
  match "/validate/:voucher_id/:token", :to => "qrcode#validate", :as => :validation
  get "/images/qrcode/:md5.png", :to => "qrcode#image"

  # Credit purchasing routes
  #match "credits/success", :to => "credits#success"
  match "ultimatepay/postback", :to => "credits#postback"

  # Paypal routes
  controller :paypal do
    post "paypal/create"
    post "paypal/ipn"
    match "paypal/confirmation/:order_id", :to => "paypal#confirmation", :via => :get
    get 'paypal/express'
    get 'paypal/complete'
  end

  get "time_zone", :to => "timezones#time_zone"

  resources :sms
  resources :email_invitations

  resources :events, :only => [:index, :new, :create] do
    collection do
      get :return_events
    end
  end

  resources :ious, :only => [:index, :new, :create, :destroy, :show] do
    member do
      get :pay
      get :confirm
      get :confirm_payment
      post :confirm_payment
      get :completed
    end
    collection do
      get :send_group_drinks
      get :get_fb_friends
    end
  end

  resources :users, :only => [:index] do
    match "credits/balance", :to => "credits#balance"
    member do
      get :button
    end
    resources :credits do
      member do
        get :success
      end
    end
    resources :friendships
  end

  get "/bars/keyser-soze-berlin-germany--2" => redirect("/bars/keyser-soze-berlin-germany")

  resources :bars do
    member do
      get :confirm
      get :submit
      put :upload_logo
    end
    resources :prices
    resources :widgets
  end
  resources :brands
  resources :beers
  resources :cities

  resources :pages, :only => :show

  match "vouchers/check", :to => "vouchers#check", :as => :check_voucher
  match "vouchers/redeem", :to => "vouchers#redeem", :as => :redeem_voucher, :via => :post
  resources :vouchers

  # short URL for vouchers
  # now being redirected to force app download
  match "b/:code", :to => "home#apps" #:to => "vouchers#shorturl", :as => :short

  # Admin routes
  namespace :admin do
    root :to => "dashboard#index"

    resources :affiliates do
      collection do
        get 'get_corporates'
      end
    end
    resources :bros
    resources :site_admins, :except => [:show]
    resources :bars do
      get :vouchers, :on => :member
      resources :prices
      resources :photos
      resources :employments
      resources :voucher_lists, :only => [:show]
      match "vouchers/:price", :to => "bars#vouchers"
      collection do
        get 'get_venues'
      end
    end
    resources :payments do
      put :toggle, :on => :member
    end
    resources :users
    resources :ious, :only => [:new, :create]
    resources :sites
    resources :pages
    resources :cities
    post 'metrics', :to => 'metrics#index'
    resources :metrics, :only => [:index]
    match "dashboard/get_users", :to => "dashboard#get_users"
    match "dashboard/get_buddybucks", :to => "dashboard#get_buddybucks"
  end

  # Site Admin routes
  namespace :site_admin do
    root :to => "dashboard#index"

    resources :affiliates
    resources :bars do
      get :vouchers, :on => :member
      resources :prices
      resources :photos
      resources :voucher_lists, :only => [:show]
      match "vouchers/:price", :to => "bars#vouchers"
    end
  end

  # Affiliate routes
  namespace :affiliate do
    root :to => "dashboard#index"

    resources :payments
    resources :payouts
    match "outstanding_payouts", :to => "payouts#outstanding_payouts"
    match "paid_vouchers", :to => "payouts#paid_vouchers"
    match "pay", :to => "payouts#pay"


    resources :bars do
      member do
        get :vouchers
        get :gallery
      end
      resources :employments
      resources :prices
      resources :ious
      resources :photos
      resources :voucher_lists, :only => [:show]
      match "vouchers/:price", :to => "bars#vouchers"
    end
  end

  namespace :bro do
    resources :bars
  end

  match "/neubar", :to => "bars#new"
  match "/newbar", :to => "bars#new"

  scope 'api(/:version)', :module => :api, :version => /v\d+?/ do
    resources :locations, :only => [:index] do
      resources :prices, :only => [:index]
    end
    resources :orders, :only => [:create]
    resources :events
    match "me", :to => "users#show"
    match "me/last_locations", :to => "users#last_locations"
    put "me/update", :to => "users#update"
    match "vouchers/received", :to => "vouchers#received"
    match "vouchers/recent", :to => "vouchers#recent"
    match "vouchers/sent", :to => "vouchers#sent"
    match "vouchers/redeemed", :to => "vouchers#redeemed"
    post "vouchers/redeem", :to => "vouchers#redeem"
  end

  namespace :facebook do
    root :to => "home#index"
    match "channel", :to => "home#channel"
    resources :orders do
      member do
        get :check
      end
    end
    resources :vouchers
    post "users/:id/grant_permissions", :to => "users#grant_permissions", :as => :grant_permissions
    resources :locations, :only => [:show, :index]
    post "locations/update_location_details", :to => "locations#update_location_details"
  end

  match "/sitemap.xml" => redirect("http://s3.amazonaws.com/buddybeers/sitemaps/sitemap_index.xml.gz")
  match "/sitemap.xml.gz" => redirect("http://s3.amazonaws.com/buddybeers/sitemaps/sitemap_index.xml.gz")

  root :to => "home#index"

  # TODO: remove
  match ":controller(/:action(/:id(.:format)))"


end
