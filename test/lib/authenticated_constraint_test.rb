require "test_helper"
require "authenticated_constraint"

class AuthenticatedConstraintTest < ActiveSupport::TestCase
  def setup
    @constraint = AuthenticatedConstraint.new
  end

  test "returns false when session_id cookie is not present" do
    request = mock_request(nil)
    assert_not @constraint.matches?(request)
  end

  test "returns false when session_id cookie is present but session does not exist" do
    request = mock_request(999999)
    assert_not @constraint.matches?(request)
  end

  test "returns true when session_id cookie matches an existing session" do
    session = sessions(:one)
    request = mock_request(session.id)
    assert @constraint.matches?(request)
  end

  test "returns true for different valid session" do
    session = sessions(:two)
    request = mock_request(session.id)
    assert @constraint.matches?(request)
  end

  private

  def mock_request(session_id)
    signed_cookies = Minitest::Mock.new
    signed_cookies.expect(:[], session_id, [ :session_id ])

    cookie_jar = Minitest::Mock.new
    cookie_jar.expect(:signed, signed_cookies)

    request = Minitest::Mock.new
    request.expect(:cookie_jar, cookie_jar)
    request
  end
end
