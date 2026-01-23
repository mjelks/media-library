class ReleasesController < ApplicationController
  def index
    @releases = Release.includes(:media_owner, :genres).order(created_at: :desc)
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

  def release_params
    params.require(:release).permit(:title, :description, :original_year, :additional_info, :media_owner_id)
  end

  def update_genres
    if params[:release][:genre_ids].present?
      @release.genre_ids = params[:release][:genre_ids].reject(&:blank?)
    end
  end
end
