require "test_helper"

module Api
  module V1
    class ProfileControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:default_user)
      end

      test "should return current user with bearer token" do
        get api_v1_me_url, headers: { "Authorization" => "Bearer #{@user.api_token}" }
        assert_response :success

        json_response = response.parsed_body
        assert_equal @user.id, json_response["id"]
        assert_equal @user.email_address, json_response["email_address"]
        assert json_response["has_api_token"]
      end

      test "should return current user with X-Api-Token header" do
        get api_v1_me_url, headers: { "X-Api-Token" => @user.api_token }
        assert_response :success

        json_response = response.parsed_body
        assert_equal @user.id, json_response["id"]
        assert_equal @user.email_address, json_response["email_address"]
      end

      test "should return unauthorized without token" do
        get api_v1_me_url
        assert_response :unauthorized
      end

      test "should return unauthorized with invalid token" do
        get api_v1_me_url, headers: { "Authorization" => "Bearer invalid_token" }
        assert_response :unauthorized
      end

      test "should return user without api token as has_api_token false" do
        user_without_token = users(:one)
        user_without_token.generate_api_token!

        get api_v1_me_url, headers: { "Authorization" => "Bearer #{user_without_token.api_token}" }
        assert_response :success

        json_response = response.parsed_body
        assert_equal user_without_token.id, json_response["id"]
        assert json_response["has_api_token"]
      end
    end
  end
end
