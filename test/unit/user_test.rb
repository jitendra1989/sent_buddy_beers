require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup { @user = Factory(:customer, :login => "johnny", :emails_attributes => {"0" => {:email => "john@doe.com"}}) }

  should belong_to(:sign_up_site)
  should have_many(:emails)
  should have_many(:credit_events)
  should validate_presence_of(:language)
  should validate_presence_of(:login)
  should validate_uniqueness_of(:login)
  should have_many(:employments).dependent(:destroy)
  should have_many(:employers).through(:employments)
  should have_many(:vouchers).through(:received_ious)
  should have_many(:metrics)
  should allow_value("1234567").for(:phone_number)
  #before validation hook should strip dashes, dots, etc.
  should allow_value("123-4567").for(:phone_number)
  should allow_value("(123) 4567").for(:phone_number)
  should allow_value("(123) 456-7333").for(:phone_number)
  should allow_value("123.456.7333").for(:phone_number)
  should allow_value("+123.456.7333").for(:phone_number)

  context "An active user" do
    should "return a name if present" do
      @user.name = "Sam Saufer"
      assert_equal "Sam Saufer", @user.to_s
    end

    should "return a pseudo name created from the login if no name is present" do
      @user.name = ""
      assert_equal 'johnny', @user.to_s, @user.emails.inspect
    end
    
    should "return a pseudo name created from the email if no name or login is present" do
      @user.name = ""
      @user.login = ""
      assert_equal 'john', @user.to_s, @user.emails.inspect
    end

    should "return an email as a string" do
      assert_equal 'john@doe.com', @user.email
    end

    should "be a customer, not an admin or affiliate" do
      assert_false @user.admin?
      assert_false @user.affiliate?
    end

    should "return true when sent #active?" do
      assert @user.active_for_authentication?
    end
    
    should "return false when sent #can_redeem_vouchers?" do
      assert !@user.can_redeem_vouchers?
    end

    context "who is an admin" do
      setup do
        @user = Factory.build(:admin)
      end

      should "return true when sent #admin?" do
        assert @user.admin?
      end
      
      should "return true when sent #can_redeem_vouchers?" do
        assert @user.can_redeem_vouchers?
      end
      
      context "with redeemable vouchers" do
        setup do 
          @iou = Factory(:iou, :price => Factory(:price, :bar => Factory(:bar)))
          @iou.paid!
        end
       
        should "have redeemable_vouchers" do
          assert @user.redeemable_vouchers.present?
          assert @user.redeemable_vouchers.to_a.include?(@iou.vouchers.first), "red: #{@user.redeemable_vouchers.inspect} iou: #{@iou.vouchers.inspect}"
        end
      end
    end

    context "who is an affiliate" do
      setup do
        @user = Factory.build(:affiliate)
      end

      should "return true when sent #admin?" do
        assert @user.affiliate?
      end
      
      should "return true when sent #can_redeem_vouchers?" do
        assert @user.can_redeem_vouchers?
      end
      
      context "with redeemable vouchers" do
        setup do
          @bar = Factory(:bar, :affiliate => @user)
          @price = Factory(:price, :bar => @bar)
          @iou = Factory(:iou, :price => @price)
          @iou.paid!
        end
       
        should "have redeemable_vouchers" do
          assert @user.redeemable_vouchers.present?
          assert @user.redeemable_vouchers.to_a.include?(@iou.vouchers.first)
        end
      end
    end

    context "who is an bro" do
      setup do
        @user = Factory.build(:bro)
      end

      should "return true when sent #bro?" do
        assert @user.bro?
      end
      
      should "return true when sent #can_redeem_vouchers?" do
        assert @user.can_redeem_vouchers?
      end
      
      context "with redeemable vouchers" do
        setup do
          @bar = Factory(:bar, :bro => @user)
          @price = Factory(:price, :bar => @bar)
          @iou = Factory(:iou, :price => @price)
          @iou.paid!
        end
       
        should "have redeemable_vouchers" do
          assert @user.redeemable_vouchers.present?
          assert @user.redeemable_vouchers.to_a.include?(@iou.vouchers.first)
        end
      end
    end
    
    context "who is an employee" do
      setup do
        Factory(:employment, :bar => Factory(:bar), :user => @user)
      end

      should "return true when sent #employee?" do
        assert @user.employee?
      end
      
      should "return true when sent #can_redeem_vouchers?" do
        assert @user.can_redeem_vouchers?
      end
      
      context "with redeemable vouchers" do
        setup do
          @price = Factory(:price, :bar => @user.employers.first)
          @iou = Factory(:iou, :price => @price)
          @iou.paid!
        end
       
        should "have redeemable_vouchers" do
          assert @user.redeemable_vouchers.present?
          assert @user.redeemable_vouchers.to_a.include?(@iou.vouchers.first)
        end
      end
    end
  end

  context "A facebook user" do
    should "return true when sent #facebook_user?" do
      @user.facebook_uid = "uid"
      assert @user.facebook_user?
    end
  end

  context "A newly registered customer" do
    setup do
      @iou = Factory(:iou, :recipient_email => "kennyfuckingp@example.com")
      @user = Factory(:unconfirmed_customer, :emails_attributes => {"0" => {:email => "kennyfuckingp@example.com"}})
    end

    should "return false when sent #active?" do
      assert_false @user.active_for_authentication?
    end

    should "not be an admin or an affiliate" do
      assert_false @user.admin?
      assert_false @user.affiliate?
    end

    should "have a primary email" do
      assert @user.emails.reload.primary.exists?
    end

    should "has a pending email" do
      assert @user.emails.pending.exists?
    end

    should "activate and have verified emails" do
      @user.confirm!
      assert @user.emails.reload.primary.exists?
      assert @user.emails.verified.exists?
      assert @user.emails.pending.blank?
    end

    should "return false when sent #facebook_user?" do
      assert !@user.facebook_user?
    end

    should "be synced with existing ious containing his email address" do
      @user.confirm!
      @user.reload
      assert Iou.find_all_by_recipient_id(@user.id).include?(@iou)
    end
    
    context "with a phone number" do
      setup do
        @user.phone_number = "491778793342"
        @iou2 = Factory(:iou, :recipient_phone => "491778793342")
      end
    
      should "be synced with existing ious containing his phone number" do
        @user.confirm!
        @user.reload
        assert Iou.find_all_by_recipient_id(@user.id).include?(@iou2)
      end
    end
  end
  
  context "an user with a phone number" do
    setup { @user = Factory.build(:unconfirmed_customer, :emails_attributes => {"0" => {:email => "kennyfuckingp@example.com"}}) }
    
    context "that has extra characters in it" do
      setup { @user.phone_number = "(904) 302-7233" }
      
      should "be stripped on save" do
        @user.save
        assert @user.phone_number.to_s == "9043027233"
      end
    end
    
    context "that has leading zeros" do
      setup { @user.phone_number = "01779878989" }
      
      should "be stripped on save" do
        @user.save
        assert @user.phone_number.to_s == "1779878989"
      end
    end
    
    context "with a country code" do
      setup do
        @user.phone_number = "(904) 302-7233"
        @user.phone_number_country_code = "1"
      end
      
      should "have it added to the phone number on save" do
        @user.save
        assert @user.phone_number.to_s == "19043027233"
      end
    end
    
    context "that is blank but has a country code" do
      setup do
        @user.phone_number = ""
        @user.phone_number_country_code = "1"
        @user.save
      end
      
      should "be blank" do
        assert @user.phone_number.blank?
      end
      
      should "be valid" do
        assert @user.valid?
      end
    end
  end

  should "try to create user but return an error on email being blank" do
    assert_no_difference 'User.count' do
      user = Factory.build(:customer, :emails_attributes => {"0" => {:email => ""}})
      assert user.invalid?
      assert user.emails.first.errors[:email]
    end
  end

  should "try to create user but return an error on email being taken" do
    Factory(:email, :email => "taken@email.com", :pending => false)
    user = Factory.build(:customer, :emails_attributes => {"0" => {:email => "taken@email.com"}})
    assert user.invalid?
    assert_not_nil user.emails.first.errors[:email]
  end

  context "#find_for_facebook_oauth" do
    setup { @site = Factory(:site) }

    should "return user with given Facebook UID if such exists" do
      existing_user = Factory(:customer, :facebook_uid => 1234567890)
      assert_equal existing_user, User.find_for_facebook_oauth(facebook_auth_data, @site)
      assert !User.find_for_facebook_oauth(facebook_auth_data, @site).facebook_app_credentials.blank?
      assert User.find_for_facebook_oauth(facebook_auth_data, @site).fb_access_token_for(@site).present?
    end

    should "find user by email and assign facebook_uid if email already exists in db" do
      existing_user = Factory(:customer, :facebook_uid => nil)
      auth_data = facebook_auth_data("email" => existing_user.email)
      user = User.find_for_facebook_oauth(auth_data, @site)

      assert_equal existing_user.id, user.id
      assert_equal auth_data["extra"]["user_hash"]["id"], user.facebook_uid
      assert_equal auth_data["credentials"]["token"], user.fb_access_token_for(@site)
    end

    should "create a new user if there's no user with given Facebook UID or email" do
      user = User.find_for_facebook_oauth(facebook_auth_data, @site)
      user_data = facebook_auth_data["extra"]["user_hash"]
      token = facebook_auth_data["credentials"]["token"]

      assert user.persisted?
      assert user.confirmed?
      assert !user.emails(true).primary.first.pending
      assert_equal user_data["id"], user.facebook_uid
      assert_equal user_data["email"], user.email
      assert_equal user_data["name"], user.name
      assert_equal user_data["email"].parameterize, user.login
      assert_equal token, user.fb_access_token_for(@site)
      assert_equal @site, user.sign_up_site
    end
  end

  protected

  def facebook_auth_data(options={})
    user_hash = {
      "id" => 1234567890,
      "email" => "mike@example.com",
      "name" => "Mike Rotch"
    }

    {
      "extra" => {"user_hash" => user_hash.merge(options)}, 
      "credentials" => {"token" => "166942940015970%7C2.sa"}
    }
  end
end
