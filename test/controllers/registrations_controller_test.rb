require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_registration_url
    assert_response :success
  end

  test "should redirect authenticated user from new" do
    user = users(:default_user)
    login_as(user)
    get new_registration_url
    assert_redirected_to root_url
    assert_equal "You are already signed in.", flash[:notice]
  end

  test "should create user and sign in" do
    assert_difference("User.count") do
      post registration_url, params: {
        email_address: "newuser@example.com",
        password: "password123"
      }
    end
    assert_redirected_to root_url
    assert_equal "Signed up.", flash[:notice]
  end

  test "should not create user with invalid data" do
    assert_no_difference("User.count") do
      post registration_url, params: {
        email_address: "",
        password: "password123"
      }
    end
    assert_redirected_to new_registration_url(email_address: "")
  end

  test "should not create user with duplicate email" do
    user = users(:default_user)
    assert_no_difference("User.count") do
      post registration_url, params: {
        email_address: user.email_address,
        password: "password123"
      }
    end
    assert_redirected_to new_registration_url(email_address: user.email_address)
  end

  test "should create session for new user" do
    assert_difference("Session.count") do
      post registration_url, params: {
        email_address: "newuser@example.com",
        password: "password123"
      }
    end
  end
end
