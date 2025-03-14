class HomepageController < ApplicationController
  allow_unauthenticated_access(only: :index)
  def index
    @carousel_albums = MediaItem.order("id ASC").limit(10)
  end

  def test
  end
end
