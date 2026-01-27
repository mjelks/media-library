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

  def destroy
    @media_item = MediaItem.find(params[:id])
    @media_item.destroy
    redirect_to media_items_path, notice: "Media item was successfully deleted."
  end

  private

  def media_item_params
    params.require(:media_item).permit(:release_id, :media_type_id, :year, :notes, :play_count, :last_played, :item_count, :artwork, :location_id)
  end
end
