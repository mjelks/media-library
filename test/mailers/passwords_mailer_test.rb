require "test_helper"

class PasswordsMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:default_user)
  end

  test "reset email is sent to user" do
    email = PasswordsMailer.reset(@user)

    assert_emails 1 do
      email.deliver_now
    end
  end

  test "reset email has correct recipient" do
    email = PasswordsMailer.reset(@user)

    assert_equal [ @user.email_address ], email.to
  end

  test "reset email has correct subject" do
    email = PasswordsMailer.reset(@user)

    assert_equal "Reset your password", email.subject
  end

  test "reset email has correct from address" do
    email = PasswordsMailer.reset(@user)

    assert_equal [ "from@example.com" ], email.from
  end

  test "reset email body contains password reset link" do
    email = PasswordsMailer.reset(@user)

    assert_match "password reset page", email.body.encoded
  end
end
