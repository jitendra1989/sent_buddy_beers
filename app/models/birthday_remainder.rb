class BirthdayRemainder
  def self.birthday_remainder_email
    users = User.where(:birthday_day => DateTime.now.in_time_zone(Time.zone).beginning_of_day)
    unless users.blank?
      users.each do |user|
        Notifier.birthday_remainder(user, user).deliver
        if user.friendships.blank?
          user.friendships.each do |friend|
            friend_obj = User.where(:id => freind.friend_id).first
            Notifier.birthday_remainder(friend_obj, user).deliver
          end
        end
      end
    end
    send_birthday_remainder_email_next_day
  end
  
  def self.send_birthday_remainder_email_next_day
    self.delay(:run_at => 24.hours.from_now).birthday_remainder_email
  end
end
