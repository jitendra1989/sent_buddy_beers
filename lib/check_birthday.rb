class CheckBirthday
  def self.birthday?(birthday_day_date, start_after_day, upcomming_days_count)
    dates_array = birthday_date = []
    date = Date.today + start_after_day.day
    upcoming_date = Date.today + upcomming_days_count.days
    dates = (date..(upcoming_date)).map{|e| e}
    dates_array = dates.map{|e| [e.day, e.month]}
    birthday_date = [birthday_day_date.day, birthday_day_date.month]
    dates_array.include? birthday_date
  end
end
