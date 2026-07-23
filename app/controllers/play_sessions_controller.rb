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

  def calendar
    @month = resolve_month

    @prev_month = @month.prev_month
    @next_month = @month.next_month
    @has_prev = @prev_month >= @earliest_month
    @has_next = @month < @latest_month

    sessions = PlaySession.all_history
                          .where(start_time: @month.beginning_of_month..@month.end_of_month.end_of_day)
                          .includes(media_item: [ :media_type, :release ])
                          .to_a
    sessions_by_day = sessions.group_by { |ps| ps.start_time.to_date }
    @counts_by_day = sessions_by_day.transform_values(&:count)
    @lp_counts_by_day = sessions_by_day.transform_values { |day_sessions| day_sessions.count { |ps| ps.media_item.media_type&.name == "Vinyl" } }
    @cd_counts_by_day = sessions_by_day.transform_values { |day_sessions| day_sessions.count { |ps| ps.media_item.media_type&.name == "CD" } }
    @total_plays = sessions.size
    @total_albums_played = sessions.map(&:media_item_id).uniq.size
    @total_seconds = sessions.sum { |ps| ps.media_item.release&.duration || 0 }
    @avg_daily_seconds = average_daily_seconds(@total_seconds, @month)

    unique_media_items = sessions.map(&:media_item).uniq(&:id)
    @lp_count = unique_media_items.count { |mi| mi.media_type&.name == "Vinyl" }
    @cd_count = unique_media_items.count { |mi| mi.media_type&.name == "CD" }

    render partial: "calendar_body", layout: false if request.xhr?
  end

  def month
    @month = resolve_month

    @play_sessions = PlaySession.all_history
                                .where(start_time: @month.beginning_of_month..@month.end_of_month.end_of_day)
                                .includes(media_item: [ :media_type, { release: [ :media_owner, :release_tracks ] } ])

    @total_seconds = @play_sessions.sum { |ps| ps.media_item.release&.duration || 0 }
  end

  def day
    @date = Date.parse(params[:date])

    @play_sessions = PlaySession.all_history
                                .where(start_time: @date.beginning_of_day..@date.end_of_day)
                                .includes(media_item: [ :media_type, { release: [ :media_owner, :release_tracks ] } ])

    @total_seconds = @play_sessions.sum { |ps| ps.media_item.release&.duration || 0 }
  rescue ArgumentError, TypeError
    redirect_to play_sessions_calendar_path, alert: "Invalid date."
  end

  private

  # Resolves the requested year/month, clamped between the earliest month
  # with any play session and the current month. Also sets @earliest_month
  # and @latest_month, which the calendar view uses to disable its arrows.
  def resolve_month
    @earliest_month = earliest_play_month
    @latest_month = Date.current.beginning_of_month
    requested_month.clamp(@earliest_month, @latest_month)
  end

  def requested_month
    year = params[:year].presence&.to_i
    month = params[:month].presence&.to_i
    return Date.current.beginning_of_month unless year && month

    Date.new(year, month, 1)
  rescue ArgumentError
    Date.current.beginning_of_month
  end

  def earliest_play_month
    earliest = PlaySession.minimum(:start_time)
    earliest ? earliest.to_date.beginning_of_month : Date.current.beginning_of_month
  end

  # Divides by the Gregorian day count for the month (28-31), regardless
  # of how much of the month has elapsed.
  def average_daily_seconds(total_seconds, month)
    (total_seconds.to_f / month.end_of_month.day).round
  end
end
