class HomepageController < ApplicationController
  allow_unauthenticated_access(only: :index)
  def index
  end
end
