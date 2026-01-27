class RecordCollectionController < ApplicationController
  CUBES = %w[A B C D E F].freeze

  def index
    @locations = Location.includes(:media_type, :media_items)
                         .joins(:media_type)
                         .where(media_types: { name: "Vinyl" })
                         .order(:position, :name)
    @cubes = CUBES
    @locations_by_cube = @locations.group_by(&:cube_location)
  end

  def show
    @location = Location.find(params[:id])
    @media_items = @location.media_items
                            .vinyl
                            .includes(release: [ :media_owner, :cover_image_attachment ])
                            .ordered

    # Spine shelf configuration (heights in pixels)
    @spine_config = {
      container_height_mobile: 180,
      container_height_desktop: 280,
      spine_height_mobile: 140,
      spine_height_desktop: 240,
      spine_text_max_height_desktop: 220
    }
  end

  def reorder
    @location = Location.find(params[:id])
    ordered_ids = params[:media_item_ids]

    if ordered_ids.present?
      MediaItem.update_positions(@location.id, ordered_ids)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def move_to_top
    @location = Location.find(params[:location_id])
    @media_item = @location.media_items.find(params[:id])

    MediaItem.move_to_top(@location.id, @media_item.id)
    redirect_to record_collection_location_path(@location), notice: "Moved to top"
  end

  def move_to_bottom
    @location = Location.find(params[:location_id])
    @media_item = @location.media_items.find(params[:id])

    MediaItem.move_to_bottom(@location.id, @media_item.id)
    redirect_to record_collection_location_path(@location), notice: "Moved to bottom"
  end

  def add_to_collection
    @location = Location.find(params[:id])
    session[:last_selected_location_id] = @location.id
    redirect_to discogs_path
  end

  def cube
    @cube_letter = params[:id].upcase
    unless CUBES.include?(@cube_letter)
      redirect_to record_collection_path, alert: "Invalid cube"
      return
    end

    @locations = Location.includes(:media_type, :media_items)
                         .joins(:media_type)
                         .where(media_types: { name: "Vinyl" })
                         .where(cube_location: @cube_letter)
                         .order(:position, :name)

    @media_items = MediaItem.vinyl
                            .joins(:location)
                            .where(locations: { id: @locations.pluck(:id) })
                            .includes(release: [ :media_owner, :cover_image_attachment ])
                            .ordered_by_location

    @spine_config = {
      container_height_mobile: 180,
      container_height_desktop: 280,
      spine_height_mobile: 140,
      spine_height_desktop: 240,
      spine_text_max_height_desktop: 220
    }
  end
end
