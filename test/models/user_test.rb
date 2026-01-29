# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  api_token       :string
#  email_address   :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_api_token      (api_token) UNIQUE
#  index_users_on_email_address  (email_address) UNIQUE
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user with all required attributes" do
    user = User.new(email_address: "test@example.com", password: "password123")
    assert user.valid?
  end

  test "requires email_address" do
    user = User.new(password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "can't be blank"
  end

  test "requires unique email_address" do
    existing_user = users(:default_user)
    user = User.new(email_address: existing_user.email_address, password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "requires valid email format" do
    user = User.new(email_address: "invalid-email", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "is invalid"
  end

  test "normalizes email_address to lowercase and strips whitespace" do
    user = User.new(email_address: "  TEST@EXAMPLE.COM  ", password: "password123")
    user.valid?
    assert_equal "test@example.com", user.email_address
  end

  test "has secure password" do
    user = users(:default_user)
    assert user.authenticate("password")
    assert_not user.authenticate("wrong_password")
  end

  test "has many sessions" do
    user = users(:default_user)
    assert_respond_to user, :sessions
    assert_kind_of ActiveRecord::Associations::CollectionProxy, user.sessions
  end

  test "destroys associated sessions when destroyed" do
    user = users(:one)
    user.sessions.create!(ip_address: "127.0.0.1", user_agent: "Test")
    session_count = user.sessions.count
    assert_difference "Session.count", -session_count do
      user.destroy
    end
  end

  test "generate_api_token! creates a new token" do
    user = users(:one)
    assert_nil user.api_token
    user.generate_api_token!
    assert_not_nil user.api_token
    assert_equal 64, user.api_token.length
  end

  test "regenerate_api_token! replaces existing token" do
    user = users(:default_user)
    old_token = user.api_token
    user.regenerate_api_token!
    assert_not_equal old_token, user.api_token
  end
end
