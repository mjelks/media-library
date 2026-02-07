class WishlistController < ApplicationController
  SORT_COLUMNS = %w[artist title year media_type date_added].freeze
  SORT_DIRECTIONS = %w[asc desc].freeze

  def index
    @sort_column = SORT_COLUMNS.include?(params[:sort]) ? params[:sort] : "date_added"
    @sort_direction = SORT_DIRECTIONS.include?(params[:direction]) ? params[:direction] : "desc"

    @wishlist_items = sorted_wishlist_items
  end

  def show
    @wishlist_item = WishlistItem.includes(:media_type, release: [ :media_owner, :release_tracks, :genres, :cover_image_attachment ]).find(params[:id])
    @release = @wishlist_item.release
  end

  def destroy
    @wishlist_item = WishlistItem.find(params[:id])
    @wishlist_item.destroy
    redirect_to wishlist_index_path, notice: "Removed from wishlist"
  end

  private

  def sorted_wishlist_items
    base = WishlistItem.includes(:media_type, release: [ :media_owner, :cover_image_attachment ])
    dir = @sort_direction.to_sym

    case @sort_column
    when "artist"
      base.joins(release: :media_owner).order("media_owners.name": dir, "releases.title": :asc)
    when "title"
      base.joins(:release).order("releases.title": dir)
    when "year"
      year_col = Release.arel_table[:original_year]
      year_order = dir == :asc ? year_col.asc.nulls_last : year_col.desc.nulls_first
      base.joins(:release).order(year_order).order("releases.title": :asc)
    when "media_type"
      mt_col = MediaType.arel_table[:name]
      mt_order = dir == :asc ? mt_col.asc.nulls_last : mt_col.desc.nulls_first
      base.left_joins(:media_type).order(mt_order).order("releases.title": :asc)
    else
      base.order(created_at: dir)
    end
  end
end
