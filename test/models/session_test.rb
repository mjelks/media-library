# == Schema Information
#
# Table name: sessions
#
#  id         :integer          not null, primary key
#  ip_address :string
#  user_agent :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_sessions_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
require "test_helper"

class SessionTest < ActiveSupport::TestCase
  test "valid session with user" do
    session = Session.new(user: users(:default_user), ip_address: "127.0.0.1", user_agent: "Test Browser")
    assert session.valid?
  end

  test "requires user" do
    session = Session.new(ip_address: "127.0.0.1", user_agent: "Test Browser")
    assert_not session.valid?
    assert_includes session.errors[:user], "must exist"
  end

  test "belongs to user" do
    session = sessions(:one)
    assert_respond_to session, :user
    assert_kind_of User, session.user
  end

  test "allows nil ip_address" do
    session = Session.new(user: users(:default_user), user_agent: "Test Browser")
    assert session.valid?
  end

  test "allows nil user_agent" do
    session = Session.new(user: users(:default_user), ip_address: "127.0.0.1")
    assert session.valid?
  end

  test "can access user attributes through association" do
    session = sessions(:one)
    assert_equal users(:default_user).email_address, session.user.email_address
  end
end
