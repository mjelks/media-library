ENV["RAILS_ENV"] ||= "test"

require "simplecov"
SimpleCov.start "rails" do
  add_filter "/test/"
  add_filter "/lib/itunes_import/"

  track_files "{app,lib}/**/*.rb"
  enable_coverage :branch

  # Coverage thresholds - CI will fail if not met
  minimum_coverage line: 40, branch: 60
  minimum_coverage_by_file line: 0  # Allow some files to have low coverage for now

  # Prevent coverage from dropping on subsequent runs
  refuse_coverage_drop :line, :branch
end

require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Configure SimpleCov for parallel tests
    parallelize_setup do |worker|
      SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
    end

    parallelize_teardown do |worker|
      SimpleCov.result
    end

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
