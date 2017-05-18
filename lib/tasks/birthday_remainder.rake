namespace :birthday_job do
  desc "birthday_remainder"
  task :birthday_remainder => :environment do
    BirthdayRemainder.birthday_remainder_email
  end 
end
