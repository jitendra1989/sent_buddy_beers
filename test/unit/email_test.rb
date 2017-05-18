require 'test_helper'

class EmailTest < ActiveSupport::TestCase
  setup { @email = Factory(:email, :email => "CamelCase@Camello.Com") }

  should belong_to(:user)

  should validate_presence_of(:email)
  should_not allow_value("a bc").for(:email)
  should_not allow_value("abc").for(:email)
  should_not allow_value("abc@").for(:email)
  should_not allow_value("abc.com").for(:email)
  should_not allow_value("wrong@email").for(:email)
  should allow_value("abc@abc.com").for(:email)

  should "automatically generate a 40 digit token on save" do
    assert_not_nil @email.token
    assert_equal 40, @email.token.length
  end

  should "return true when passed #pending?" do
    assert @email.pending?
  end
  
  should "be lowercase" do
    assert_equal @email.email, "camelcase@camello.com"
  end

  should "require verification" do
    assert @email.requires_verification?
  end

  should "return true when passed notified? after save" do
    assert @email.notified?
  end

  should "save correctly with trailing or leading spaces" do
    email = Factory.build(:email, :email => " email@example.com  ")
    assert email.valid?
    assert_equal "email@example.com", email.email
  end

  context "not pending" do
    setup { @email = Factory(:email, :pending => false) }

    should "return true when passed matching_active_email?" do
      assert @email.matching_active_email?
    end

    should "return true when passed only_email?" do
      assert @email.only_email?
    end

    should "be unique" do
      email = Factory.build(:email, :email => @email.email)
      assert email.invalid?
      assert_not_nil email.errors[:email]
    end
  end

  context "without user" do
    setup { @email = Factory(:email, :user => nil) }

    should "be set to primary with no user" do
      assert @email.primary
    end

    should "return false when passed notified?" do
      assert_false @email.notified?
    end
  end

  context "with a user who has other emails" do
    setup { @other_email = Factory(:email, :user => @email.user) }

    should "not be set primary" do
      assert_false @other_email.primary
    end

    should "return false when passed only_email?" do
      assert_false @other_email.only_email?
    end
  end
end
