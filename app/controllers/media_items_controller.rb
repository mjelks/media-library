class MediaItemsController < ApplicationController
  def index
    @media_items = MediaItem.includes(release: :media_owner).order(created_at: :desc)
  end

  def show
    @media_item = MediaItem.includes(release: [ :media_owner, :genres, :release_tracks ]).find(params[:id])
  end

  def new
    @media_item = MediaItem.new
    @releases = Release.includes(:media_owner).order(:title)
    @media_types = MediaType.order(:name)
    @locations = Location.order(:name)
  end

  def create
    @media_item = MediaItem.new(media_item_params)
    if @media_item.save
      redirect_to @media_item, notice: "Media item was successfully created."
    else
      @releases = Release.includes(:media_owner).order(:title)
      @media_types = MediaType.order(:name)
      @locations = Location.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @media_item = MediaItem.find(params[:id])
    @releases = Release.includes(:media_owner).order(:title)
    @media_types = MediaType.order(:name)
    @locations = Location.order(:name)
  end

  def update
    @media_item = MediaItem.find(params[:id])
    if @media_item.update(media_item_params)
      redirect_to @media_item, notice: "Media item was successfully updated."
    else
      @releases = Release.includes(:media_owner).order(:title)
      @media_types = MediaType.order(:name)
      @locations = Location.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def clone
    source = MediaItem.find(params[:id])
    @media_item = source.dup
    @media_item.play_count = 0
    @media_item.last_played = nil
    @media_item.currently_playing = false
    @media_item.listening_confirmed = false
    @media_item.slot_position = nil
    @media_item.position = nil
    @media_item.disc_number = (source.disc_number || 1) + 1
    @media_item.additional_info = "(Disc #{@media_item.disc_number})"

    if @media_item.save
      if source.location_id.present? && source.slot_position.present?
        MediaItem.move_slot_to_bottom(source.location_id, @media_item.id)
      end
      redirect_to edit_media_item_path(@media_item), notice: "Cloned successfully. Update the additional info for this disc."
    else
      redirect_to media_item_path(source), alert: "Failed to clone media item."
    end
  end

  def destroy
    @media_item = MediaItem.find(params[:id])
    @media_item.destroy
    redirect_to media_items_path, notice: "Media item was successfully deleted."
  end

  private

  def media_item_params
    params.require(:media_item).permit(:release_id, :media_type_id, :year, :notes, :play_count, :last_played, :item_count, :additional_info, :disc_number, :artwork, :location_id)
  end
end
