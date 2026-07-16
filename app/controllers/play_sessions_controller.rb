class PlaySessionsController < ApplicationController
  before_action :require_admin!

  def index
    @cartridge = LpCartridge.find(params[:lp_cartridge_id])

    @media_items = MediaItem.vinyl
                            .where("last_played >= ?", @cartridge.installed_at)
                            .where.not(last_played: nil)
                            .includes(release: [ :media_owner, :release_tracks ])
                            .order(last_played: :desc)

    @total_seconds = @media_items.sum { |item| item.release&.duration || 0 }
  end
end
