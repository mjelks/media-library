class PlaylistController < ApplicationController
  before_action :require_admin!

  def create
    media_item = MediaItem.find(params[:media_item_id])

    if Playlist.active.exists?(media_item_id: media_item.id)
      render json: { success: true, already_queued: true }
      return
    end

    playlist_item = Playlist.create!(media_item: media_item, position: Playlist.next_position)

    html = render_to_string(
      partial: "now_playing/playlist_item",
      locals: { playlist_item: playlist_item },
      formats: [ :html ]
    )

    render json: { success: true, html: html }
  end

  def destroy
    playlist_item = Playlist.find(params[:id])
    playlist_item.update!(played: true)

    respond_to do |format|
      format.json { render json: { success: true } }
      format.html { redirect_to now_playing_path }
    end
  end

  def reorder
    ids = params[:playlist_ids] || []
    Playlist.transaction do
      ids.each_with_index do |id, index|
        Playlist.where(id: id).update_all(position: index + 1)
      end
    end
    render json: { success: true }
  end

  def play
    playlist_item = Playlist.find(params[:id])
    media_item = playlist_item.media_item

    Playlist.transaction do
      playlist_item.update!(played: true)

      PlaySession.where(media_item: MediaItem.where(currently_playing: true), end_time: nil)
                 .update_all(end_time: Time.current)
      MediaItem.where(currently_playing: true).update_all(currently_playing: false)

      media_item.update!(
        play_count: (media_item.play_count || 0) + 1,
        last_played: Time.current,
        currently_playing: true,
        listening_confirmed: false
      )
      media_item.play_sessions.create!(start_time: Time.current)
    end

    respond_to do |format|
      format.html { redirect_to now_playing_path }
      format.json { render json: { success: true } }
    end
  end
end
