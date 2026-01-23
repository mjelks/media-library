require "httparty"

class Discogs
  include HTTParty
  base_uri "https://api.discogs.com"

  def initialize(token = nil)
    @token = token || ENV["DISCOGS_TOKEN"]
    raise ArgumentError, "Discogs token is required" if @token.nil? || @token.empty?
  end

  # Search the Discogs database
  # @param query [String] Search query
  # @param options [Hash] Additional search parameters
  # @option options [String] :type Filter by type (release, master, artist, label)
  # @option options [String] :title Search by title
  # @option options [String] :artist Search by artist
  # @option options [Integer] :page Page number (default: 1)
  # @option options [Integer] :per_page Results per page (default: 50, max: 100)
  # @return [Hash] Search results from Discogs API
  def search(query, options = {})
    params = { q: query, token: @token }.merge(options)
    response = self.class.get("/database/search", query: params)

    if response.success?
      response.parsed_response
    else
      { error: "API request failed", status: response.code, message: response.message }
    end
  end

  # Get release by ID
  # @param release_id [Integer] The Discogs release ID
  # @return [Hash] Release details
  def get_release(release_id)
    response = self.class.get("/releases/#{release_id}", query: { token: @token })

    if response.success?
      response.parsed_response
    else
      { error: "API request failed", status: response.code, message: response.message }
    end
  end

  # Get master release by ID
  # @param master_id [Integer] The Discogs master release ID
  # @return [Hash] Master release details
  def get_master(master_id)
    response = self.class.get("/masters/#{master_id}", query: { token: @token })

    if response.success?
      response.parsed_response
    else
      { error: "API request failed", status: response.code, message: response.message }
    end
  end

  # Get artist by ID
  # @param artist_id [Integer] The Discogs artist ID
  # @return [Hash] Artist details
  def get_artist(artist_id)
    response = self.class.get("/artists/#{artist_id}", query: { token: @token })

    if response.success?
      response.parsed_response
    else
      { error: "API request failed", status: response.code, message: response.message }
    end
  end
end
