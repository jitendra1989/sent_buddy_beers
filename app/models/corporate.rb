class Corporate < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :encryptable, :encryptor => :authlogic_sha512

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me#, :password_salt
  attr_accessible :company_name, :no_of_employees, :company_logo, :phone_number
  attr_accessor :current_password
  attr_accessible :buddy_groups_attributes
  NO_OF_EMPLOYEES= ['1 - 50','50 - 100','101 - 500','501 - 1000','> 1000']
                    
  paperclip_opts = {
    :styles => { :full => "690x460", :standard => "270x115#", :square => "100x100#", :thumb => "50x50#" }
  }

  unless Rails.env.development?
    paperclip_opts.merge! :storage        => :s3,
                          :s3_credentials => "#{Rails.root}/config/s3.yml",
                          :path => "/:style/:filename"
  end

  has_attached_file :company_logo, paperclip_opts
  
  has_many :buddy_groups, :as => :groupable
  accepts_nested_attributes_for :buddy_groups, :allow_destroy => true, :reject_if => proc { |attributes| attributes['name'].blank? }
  def authenticate(email="", login_password="")
    corporate = Corporate.find_by_email(email)
    if corporate && corporate.valid_password?(login_password)
      return corporate
    else
      return false
    end
  end  
  
  alias :devise_valid_password? :valid_password?
  def valid_password?(password="")
    begin
      devise_valid_password?(password)
      rescue BCrypt::Errors::InvalidHash
      stretches = 20
      digest = [password, self.password_salt].flatten.join('')
      stretches.times {digest = Digest::SHA512.hexdigest(digest)}
      if digest == self.encrypted_password
        self.encrypted_password = self.password_digest(password)
        self.save
      return true
      else
        # If not BCryt password and not old Authlogic SHA512 password Dosn't my user
        return false
      end
    end
  end 
  def delete_pic?
    self.company_logo = nil
    self.save!
  end
end
