require "test_helper"

module Api
  module V1
    class BaseControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:default_user)
      end

      test "should authenticate with bearer token" do
        get api_v1_widget_search_url, params: { q: "test" },
          headers: { "Authorization" => "Bearer #{@user.api_token}" }
        assert_response :success
      end

      test "should authenticate with X-Api-Token header" do
        get api_v1_widget_search_url, params: { q: "test" },
          headers: { "X-Api-Token" => @user.api_token }
        assert_response :success
      end

      test "should return unauthorized without token" do
        get api_v1_widget_search_url, params: { q: "test" }
        assert_response :unauthorized

        json_response = response.parsed_body
        assert_equal "Unauthorized", json_response["error"]
      end

      test "should return unauthorized with invalid token" do
        get api_v1_widget_search_url, params: { q: "test" },
          headers: { "Authorization" => "Bearer invalid_token" }
        assert_response :unauthorized
      end

      test "should return unauthorized with empty bearer token" do
        get api_v1_widget_search_url, params: { q: "test" },
          headers: { "Authorization" => "Bearer " }
        assert_response :unauthorized
      end

      test "should return unauthorized when user has no api token" do
        user_without_token = users(:one)
        user_without_token.update!(api_token: nil)

        get api_v1_widget_search_url, params: { q: "test" },
          headers: { "X-Api-Token" => "some_random_token" }
        assert_response :unauthorized
      end
    end
  end
end
