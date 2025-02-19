require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
    login_as(@user)
  end

  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: { user: { email_address: "foo@biz.org", password_digest: "askfdjaksfdjs" } }
    end

    assert_redirected_to user_url(User.last)
  end

  test "should NOT create user" do
    post users_url, params: { user: { email_address: "foo", password_digest: "" } }
    assert_response :unprocessable_entity
  end

  test "should show user" do
    get user_url(@user)
    assert_response :success
  end

  test "should get edit" do
    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    patch user_url(@user), params: { user: { email_address: "one@example.org", password_digest: "password" } }
    assert_redirected_to user_url(@user)
  end

  test "it should NOT update user" do
    # empty password example
    patch user_url(@user), params: { user: { email_address: "one@example.org", password_digest: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy user" do
    assert_difference("User.count", -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end
end
