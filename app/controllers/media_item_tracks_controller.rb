class MediaItemTracksController < ApplicationController
  before_action :set_media_item_track, only: %i[ show edit update destroy ]

  # GET /media_item_tracks or /media_item_tracks.json
  def index
    @media_item_tracks = MediaItemTrack.all
  end

  # GET /media_item_tracks/1 or /media_item_tracks/1.json
  def show
  end

  # GET /media_item_tracks/new
  def new
    @media_item_track = MediaItemTrack.new
  end

  # GET /media_item_tracks/1/edit
  def edit
  end

  # POST /media_item_tracks or /media_item_tracks.json
  def create
    @media_item_track = MediaItemTrack.new(media_item_track_params)

    respond_to do |format|
      if @media_item_track.save
        format.html { redirect_to @media_item_track, notice: "Media item track was successfully created." }
        format.json { render :show, status: :created, location: @media_item_track }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @media_item_track.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /media_item_tracks/1 or /media_item_tracks/1.json
  def update
    respond_to do |format|
      if @media_item_track.update(media_item_track_params)
        format.html { redirect_to @media_item_track, notice: "Media item track was successfully updated." }
        format.json { render :show, status: :ok, location: @media_item_track }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @media_item_track.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /media_item_tracks/1 or /media_item_tracks/1.json
  def destroy
    @media_item_track.destroy!

    respond_to do |format|
      format.html { redirect_to media_item_tracks_path, status: :see_other, notice: "Media item track was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_media_item_track
      @media_item_track = MediaItemTrack.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def media_item_track_params
      params.expect(media_item_track: [ :name, :play_count, :media_item_id ])
    end
end
