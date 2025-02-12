require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should be able to login" do
    @user = users(:default_user)
    post session_url, params: { email_address: @user.email_address, password: "password" }  # Use the actual password
    assert_redirected_to root_url
    assert @user.id > 0
  end
  test "should throw error message on invalid login" do
    @user = users(:default_user)
    post session_url, params: { email_address: @user.email_address, password: "passwordbad" }  # Use the actual password
    assert_redirected_to new_session_url
    assert_equal "Try another email address or password.", flash[:alert]
  end

  test "should destroy session" do
    @user = users(:default_user)
    post session_url, params: { email_address: @user.email_address, password: "password" }  # Use the actual password
    assert_redirected_to root_url
    assert @user.id > 0
    delete session_url
    follow_redirect! if response.redirect?
    assert_select "h1", "Sign in"
  end

  test "should redirect and hit request_authentication" do
    # you can use _any_ protected URL behind the login to trigger this
    get users_url
    follow_redirect!
    assert_response :success
  end
end
