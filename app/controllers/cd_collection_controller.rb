class CdCollectionController < ApplicationController
  BINDERS = [ "Binder 1", "Binder 2" ].freeze
  PAGES_PER_BINDER = 25
  SLOTS_PER_SIDE = 4
  SLOTS_PER_PAGE = 8

  def index
    @locations = Location.includes(:media_type, :media_items)
                         .joins(:media_type)
                         .where(media_types: { name: "CD" })
                         .order(:position, :name)
    @binders = BINDERS
    @locations_by_binder = @locations.index_by(&:name)
    @total_releases = MediaItem.cd.count
    @total_cds = MediaItem.cd.sum(:item_count)
  end

  def show
    @location = Location.find(params[:id])
    @media_items = @location.media_items
                            .cd
                            .includes(release: [ :media_owner, :cover_image_attachment ])
                            .ordered

    # Build a hash mapping position to media_item for easy lookup
    @items_by_position = @media_items.index_by(&:position)

    @pages_per_binder = PAGES_PER_BINDER
    @slots_per_side = SLOTS_PER_SIDE
    @slots_per_page = SLOTS_PER_PAGE
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
    redirect_to cd_collection_location_path(@location), notice: "Moved to top"
  end

  def move_to_bottom
    @location = Location.find(params[:location_id])
    @media_item = @location.media_items.find(params[:id])

    MediaItem.move_to_bottom(@location.id, @media_item.id)
    redirect_to cd_collection_location_path(@location), notice: "Moved to bottom"
  end

  def add_to_collection
    @location = Location.find(params[:id])
    session[:last_selected_location_id] = @location.id
    redirect_to discogs_path(format: "cd")
  end
end
