require "test_helper"

module ApplicationCable
  class ConnectionTest < ActionCable::Connection::TestCase
    setup do
      @user = users(:default_user)
      @session = sessions(:one)
    end

    test "connects with valid session cookie" do
      cookies.signed[:session_id] = @session.id

      connect

      assert_equal @user, connection.current_user
    end

    test "rejects connection without session cookie" do
      assert_reject_connection { connect }
    end

    test "rejects connection with invalid session id" do
      cookies.signed[:session_id] = -1

      assert_reject_connection { connect }
    end

    test "rejects connection with nil session cookie" do
      cookies.signed[:session_id] = nil

      assert_reject_connection { connect }
    end
  end
end
