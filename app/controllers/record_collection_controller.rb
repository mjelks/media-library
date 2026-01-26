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
end
