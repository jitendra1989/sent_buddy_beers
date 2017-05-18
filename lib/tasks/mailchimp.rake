namespace :mailchimp do
  desc "Subscribe all active users to our list"
  task :subscribe => :environment do
    User.active.each do |user|
      user.subscribe_to_mailchimp!
    end
  end

  desc "Subscribe users relevent to shutdown to shutdown newsletter list"
  task :shutdown_subscription => :environment do
    gb = Gibbon::API.new("4d33aaab5917dc47cb8f166c3f92c3ed-us1")

    list_id = "c43b28a76e"

    users = User.active.where('last_sign_in_at >= ?', 4.months.ago)
    users += Iou.outstanding.where('recipient_id is not null').map{ |i| i.recipient }.uniq
    users.uniq!

    users.each do |user|
      case user.language.to_s
      when "de"
        lang = "German"
      when "th"
        lang = "Thai"
      when "fr"
        lang = "French"
      when "it"
        lang = "Italian"
      else
        lang = "English"
      end

      mailchimp_attr = {:id => list_id, :email_address => user.email,
        :update_existing => true, :merge_vars => { :groupings => [{'name' => 'Language', 'groups' => lang}],
        :optin_time => user.confirmed_at.to_s(:db), :fname => (user.to_s.split(" ") - [user.to_s.split(" ").last]).join(" "),
        :lname => user.to_s.split(" ").last }, :double_optin => false}

      mailchimp_attr[:merge_vars].merge!({:optin_ip => user.last_sign_in_ip}) if user.last_sign_in_ip.present?

      gb.list_subscribe(mailchimp_attr)
    end
  end
end