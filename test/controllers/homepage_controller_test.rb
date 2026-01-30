require "test_helper"

class HomepageControllerTest < ActionDispatch::IntegrationTest
  test "should get index without authentication" do
    get root_url
    assert_response :success
  end

  test "should get index with authentication" do
    user = users(:default_user)
    login_as(user)
    get root_url
    assert_response :success
  end

  test "should assign carousel albums" do
    get root_url
    assert_response :success
  end

  test "should require authentication for test action" do
    get test_url
    assert_redirected_to new_session_path
  end

  test "should get test when authenticated" do
    user = users(:default_user)
    login_as(user)
    get test_url
    assert_response :success
  end
end
