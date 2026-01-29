ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "simplecov"
SimpleCov.start "rails" do
  add_filter "/test/"
  add_filter "/lib/itunes_import/"

  track_files "{app,lib}/**/*.rb"
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module LoginHelper
  def login_as(user)
    post session_path, params: { email_address: user.email_address, password: "password" }
    assert_response :redirect
  end
end

class ActionDispatch::IntegrationTest
  include LoginHelper
end
