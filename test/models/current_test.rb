require "test_helper"

class CurrentTest < ActiveSupport::TestCase
  teardown do
    Current.reset
  end

  test "can set and get session attribute" do
    session = sessions(:one)
    Current.session = session
    assert_equal session, Current.session
  end

  test "delegates user to session" do
    session = sessions(:one)
    Current.session = session
    assert_equal session.user, Current.user
  end

  test "user returns nil when session is nil" do
    Current.session = nil
    assert_nil Current.user
  end
end
