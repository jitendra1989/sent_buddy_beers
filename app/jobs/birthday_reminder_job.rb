require 'timeout'

class BirthdayReminderJob
  TIMEOUT_SECONDS = 180

  def perform
    Timeout::timeout(TIMEOUT_SECONDS) do
      users = User.where(:birthday_day => DateTime.now.in_time_zone(Time.zone).beginning_of_day)
      users.each do |user|
        user.send_birthday_remainder_email
      end
      Delayed::Job.enqueue BirthdayReminderJob.new, {:priority => 0, :run_at => 1.day.from_now.beginning_of_day}
    end
  end
end
