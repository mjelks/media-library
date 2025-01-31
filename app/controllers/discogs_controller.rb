class HomepageController < ApplicationController
  allow_unauthenticated_access

  def search
    response = HTTParty.get("https://api.discogs.com/database/search",
      query: { q: "Level 42 Guaranteed", token: Rails.application.credentials.discogs[:token] }
    )

    response
  end
end
