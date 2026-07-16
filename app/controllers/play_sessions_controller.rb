class PlaySessionsController < ApplicationController
  before_action :require_admin!

  def index
    @cartridge = LpCartridge.find(params[:lp_cartridge_id])

    @media_items = MediaItem.vinyl
                            .where("last_played >= ?", @cartridge.installed_at)
                            .where.not(last_played: nil)
                            .includes(:media_type, release: [ :media_owner, :release_tracks ])
                            .order(last_played: :desc)

    @total_seconds = @media_items.sum { |item| item.release&.duration || 0 }
  end

  def recent
    @days = params[:days].presence&.to_i
    @heading = @days ? "Last #{@days} Days" : "Lifetime"

    scope = @days ? PlaySession.recent(@days) : PlaySession.all_history
    @play_sessions = scope.includes(media_item: [ :media_type, { release: [ :media_owner, :release_tracks ] } ])

    @total_seconds = @play_sessions.sum { |ps| ps.media_item.release&.duration || 0 }
  end
end
