class ReleasesController < ApplicationController
  def index
    redirect_to vinyl_releases_path
  end

  PER_PAGE = 24

  def vinyl
    @media_type = "Vinyl"
    load_paginated_releases(
      MediaItem.vinyl,
      "locations.position ASC, locations.name ASC, media_items.position ASC"
    )
  end

  def cd
    @media_type = "CD"
    load_paginated_releases(
      MediaItem.cd,
      "locations.position ASC, locations.name ASC, media_items.slot_position ASC"
    )
  end

  def show
    @release = Release.includes(:media_owner, :genres, :release_tracks, media_items: :media_type).find(params[:id])
  end

  def new
    @release = Release.new
    @media_owners = MediaOwner.order(:name)
    @genres = Genre.order(:name)
  end

  def create
    @release = Release.new(release_params)
    if @release.save
      update_genres
      redirect_to @release, notice: "Release was successfully created."
    else
      @media_owners = MediaOwner.order(:name)
      @genres = Genre.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @release = Release.find(params[:id])
    @media_owners = MediaOwner.order(:name)
    @genres = Genre.order(:name)
  end

  def update
    @release = Release.find(params[:id])
    if @release.update(release_params)
      update_genres
      redirect_to @release, notice: "Release was successfully updated."
    else
      @media_owners = MediaOwner.order(:name)
      @genres = Genre.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @release = Release.find(params[:id])
    @release.destroy
    redirect_to releases_path, notice: "Release was successfully deleted."
  end

  private

  def load_paginated_releases(scope, order_clause)
    if params[:no_duration]
      @releases = Release.includes(:media_owner, :genres, :cover_image_attachment)
                         .joins(:media_items)
                         .joins("LEFT OUTER JOIN locations ON locations.id = media_items.location_id")
                         .merge(scope)
                         .where(no_duration_filter)
                         .order(order_clause)
                         .distinct
      @total = @releases.size
      @page = 0
      @has_more = false
      return render :index
    end

    base = Release.joins(:media_items).merge(scope).distinct
    @total = base.count
    @page = (params[:page] || 0).to_i
    @releases = Release.includes(:media_owner, :genres, :cover_image_attachment)
                       .joins(:media_items)
                       .joins("LEFT OUTER JOIN locations ON locations.id = media_items.location_id")
                       .merge(scope)
                       .order(order_clause)
                       .distinct
                       .limit(PER_PAGE)
                       .offset(@page * PER_PAGE)
    @has_more = (@page + 1) * PER_PAGE < @total

    if @page > 0
      response.set_header("X-Next-Page-Url", @has_more ? next_page_url : "")
      render partial: "release_cards", layout: false
    else
      render :index
    end
  end

  def next_page_url
    extra = params[:no_duration] ? { no_duration: true } : {}
    case @media_type
    when "Vinyl" then vinyl_releases_path(extra.merge(page: @page + 1))
    when "CD"    then cd_releases_path(extra.merge(page: @page + 1))
    end
  end

  def no_duration_filter
    "releases.id NOT IN (SELECT release_id FROM release_tracks WHERE duration IS NOT NULL AND duration != '')"
  end

  def release_params
    params.require(:release).permit(:title, :description, :original_year, :additional_info, :media_owner_id,
                                    release_tracks_attributes: [ :id, :duration ])
  end

  def update_genres
    if params[:release][:genre_ids].present?
      @release.genre_ids = params[:release][:genre_ids].reject(&:blank?)
    end
  end
end
