require 'yaml'

ActiveRecord::Migration.say_with_time("Loading countries") do
  if Country.all.blank?
    YAML.load_file("db/seeds/countries.yml").each { |country_attributes| Country.create(country_attributes) }
  end
end

ActiveRecord::Migration.say_with_time("Creating default site") do
  Site.find_or_create_by_name_and_subdomain_and_code_name(:name => "BuddyBeers", :subdomain => nil, :code_name => "buddybeers")
end

ActiveRecord::Migration.say_with_time("Pouring beverage...") do
  Beverage.find_or_create_by_name(:name => "Beer")
end

ActiveRecord::Migration.say_with_time("Conquoring Germany...") do
  country = Country.find_by_iso("DE")
  YAML.load_file("db/seeds/german_cities.yml").each do |city|
    City.find_or_create_by_name_and_country_id(:name => city[:name], :country_id => country.id)
  end unless country.nil?
end