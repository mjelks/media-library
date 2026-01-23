require "test_helper"
require "minitest/mock"
require "discogs"

class DiscogsTest < ActiveSupport::TestCase
  def setup
    @token = "test_token_123"
    @discogs = Discogs.new(@token)
  end

  # Initialization tests
  test "initializes with provided token" do
    discogs = Discogs.new("my_token")
    assert_not_nil discogs
  end

  test "initializes with ENV token when no token provided" do
    ENV["DISCOGS_TOKEN"] = "env_token"
    discogs = Discogs.new
    assert_not_nil discogs
  ensure
    ENV.delete("DISCOGS_TOKEN")
  end

  test "raises ArgumentError when token is nil and ENV not set" do
    ENV.delete("DISCOGS_TOKEN")
    assert_raises(ArgumentError) do
      Discogs.new(nil)
    end
  end

  test "raises ArgumentError when token is empty string" do
    assert_raises(ArgumentError) do
      Discogs.new("")
    end
  end

  # Search tests
  test "search returns parsed response on success" do
    mock_response = mock_success_response({ "results" => [ { "title" => "Test Album" } ] })
    Discogs.stub :get, mock_response do
      result = @discogs.search("test query")
      assert_equal({ "results" => [ { "title" => "Test Album" } ] }, result)
    end
  end

  test "search passes query and token as params" do
    mock_response = mock_success_response({ "results" => [] })
    called_with = nil

    Discogs.stub :get, ->(path, options) {
      called_with = { path: path, options: options }
      mock_response
    } do
      @discogs.search("test query")
    end

    assert_equal "/database/search", called_with[:path]
    assert_equal "test query", called_with[:options][:query][:q]
    assert_equal @token, called_with[:options][:query][:token]
  end

  test "search merges additional options" do
    mock_response = mock_success_response({ "results" => [] })
    called_with = nil

    Discogs.stub :get, ->(path, options) {
      called_with = options
      mock_response
    } do
      @discogs.search("test", type: "release", per_page: 25)
    end

    assert_equal "release", called_with[:query][:type]
    assert_equal 25, called_with[:query][:per_page]
  end

  test "search returns error hash on failure" do
    mock_response = mock_failure_response(401, "Unauthorized")
    Discogs.stub :get, mock_response do
      result = @discogs.search("test")
      assert_equal "API request failed", result[:error]
      assert_equal 401, result[:status]
      assert_equal "Unauthorized", result[:message]
    end
  end

  # Get release tests
  test "get_release returns parsed response on success" do
    mock_response = mock_success_response({ "id" => 123, "title" => "Test Release" })
    Discogs.stub :get, mock_response do
      result = @discogs.get_release(123)
      assert_equal({ "id" => 123, "title" => "Test Release" }, result)
    end
  end

  test "get_release calls correct endpoint" do
    mock_response = mock_success_response({})
    called_with = nil

    Discogs.stub :get, ->(path, options) {
      called_with = { path: path, options: options }
      mock_response
    } do
      @discogs.get_release(456)
    end

    assert_equal "/releases/456", called_with[:path]
    assert_equal @token, called_with[:options][:query][:token]
  end

  test "get_release returns error hash on failure" do
    mock_response = mock_failure_response(404, "Not Found")
    Discogs.stub :get, mock_response do
      result = @discogs.get_release(999)
      assert_equal "API request failed", result[:error]
      assert_equal 404, result[:status]
      assert_equal "Not Found", result[:message]
    end
  end

  # Get master tests
  test "get_master returns parsed response on success" do
    mock_response = mock_success_response({ "id" => 789, "title" => "Test Master" })
    Discogs.stub :get, mock_response do
      result = @discogs.get_master(789)
      assert_equal({ "id" => 789, "title" => "Test Master" }, result)
    end
  end

  test "get_master calls correct endpoint" do
    mock_response = mock_success_response({})
    called_with = nil

    Discogs.stub :get, ->(path, options) {
      called_with = { path: path, options: options }
      mock_response
    } do
      @discogs.get_master(321)
    end

    assert_equal "/masters/321", called_with[:path]
    assert_equal @token, called_with[:options][:query][:token]
  end

  test "get_master returns error hash on failure" do
    mock_response = mock_failure_response(500, "Internal Server Error")
    Discogs.stub :get, mock_response do
      result = @discogs.get_master(999)
      assert_equal "API request failed", result[:error]
      assert_equal 500, result[:status]
      assert_equal "Internal Server Error", result[:message]
    end
  end

  # Get artist tests
  test "get_artist returns parsed response on success" do
    mock_response = mock_success_response({ "id" => 100, "name" => "Test Artist" })
    Discogs.stub :get, mock_response do
      result = @discogs.get_artist(100)
      assert_equal({ "id" => 100, "name" => "Test Artist" }, result)
    end
  end

  test "get_artist calls correct endpoint" do
    mock_response = mock_success_response({})
    called_with = nil

    Discogs.stub :get, ->(path, options) {
      called_with = { path: path, options: options }
      mock_response
    } do
      @discogs.get_artist(200)
    end

    assert_equal "/artists/200", called_with[:path]
    assert_equal @token, called_with[:options][:query][:token]
  end

  test "get_artist returns error hash on failure" do
    mock_response = mock_failure_response(403, "Forbidden")
    Discogs.stub :get, mock_response do
      result = @discogs.get_artist(999)
      assert_equal "API request failed", result[:error]
      assert_equal 403, result[:status]
      assert_equal "Forbidden", result[:message]
    end
  end

  private

  def mock_success_response(parsed_body)
    mock = Minitest::Mock.new
    mock.expect(:success?, true)
    mock.expect(:parsed_response, parsed_body)
    mock
  end

  def mock_failure_response(code, message)
    mock = Minitest::Mock.new
    mock.expect(:success?, false)
    mock.expect(:code, code)
    mock.expect(:message, message)
    mock
  end
end
