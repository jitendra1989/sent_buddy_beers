class Corporates::PasswordsController < Devise::PasswordsController
  #before_filter :require_corporate
  layout 'corporate_program'
  
end
