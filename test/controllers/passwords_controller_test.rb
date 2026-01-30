require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
  end

  test "should get new" do
    get new_password_url
    assert_response :success
  end

  test "should create password reset and redirect" do
    post passwords_url, params: { email_address: @user.email_address }
    assert_redirected_to new_session_path
    assert_equal "Password reset instructions sent (if user with that email address exists).", flash[:notice]
  end

  test "should create password reset for non-existent email without revealing user existence" do
    post passwords_url, params: { email_address: "nonexistent@example.com" }
    assert_redirected_to new_session_path
    assert_equal "Password reset instructions sent (if user with that email address exists).", flash[:notice]
  end

  test "should enqueue password reset email" do
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      post passwords_url, params: { email_address: @user.email_address }
    end
  end

  test "should get edit with valid token" do
    token = @user.password_reset_token
    get edit_password_url(token: token)
    assert_response :success
  end

  test "should redirect with invalid token" do
    get edit_password_url(token: "invalid_token")
    assert_redirected_to new_password_path
    assert_equal "Password reset link is invalid or has expired.", flash[:alert]
  end

  test "should update password with valid token" do
    token = @user.password_reset_token
    patch password_url(token: token), params: {
      password: "newpassword123",
      password_confirmation: "newpassword123"
    }
    assert_redirected_to new_session_path
    assert_equal "Password has been reset.", flash[:notice]
  end

  test "should not update password when passwords do not match" do
    token = @user.password_reset_token
    patch password_url(token: token), params: {
      password: "newpassword123",
      password_confirmation: "differentpassword"
    }
    assert_redirected_to edit_password_path(token)
    assert_equal "Passwords did not match.", flash[:alert]
  end
end
