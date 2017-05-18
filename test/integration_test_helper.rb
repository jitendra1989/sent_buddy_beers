require "test_helper"
require "capybara/rails"

# fix of https://github.com/brynary/rack-test/issues/#issue/12
module Rack::Test::Utils
  def build_primitive_part(parameter_name, value)
    unless value.is_a? Array
      value = [value]
    end
    value.map do |v|
<<-EOF
--#{Rack::Test::MULTIPART_BOUNDARY}\r
Content-Disposition: form-data; name="#{parameter_name}"\r
\r
#{v}\r
EOF
    end.join
  end
end

# Hack to support Capybara.app_host for RackTest driver
# https://github.com/jnicklas/capybara/issues#issue/234
class Capybara::Driver::RackTest
  def process(method, path, attributes = {})
    return if path.gsub(/^#{request_path}/, '') =~ /^#/
    path = request_path + path if path =~ /^\?/
    path = Capybara.app_host + path if Capybara.app_host and path.start_with?('/')
    send(method, to_binary(path), to_binary( attributes ), env)
    follow_redirects!
  end

  def submit(method, path, attributes)
    path = request_path if not path or path.empty?
    path = Capybara.app_host + path if Capybara.app_host and path.start_with?('/')
    send(method, to_binary(path), to_binary(attributes), env)
    follow_redirects!
  end
end

# We can't use default "www.example.com" domain,
# as it causes redirect to "example.com"
Capybara.app_host = "http://test.host"

class ActionController::IntegrationTest
  include Capybara

  def sign_in(user)
    user = user.is_a?(Symbol) ? Factory(user) : user

    visit destroy_user_session_path
    visit new_user_session_path

    fill_in "Username", :with => user.login
    fill_in "Password", :with => user.password

    click_button "Login"
  end
end
