class PickRandomConfigsController < ApplicationController
  before_action :require_admin!

  PER_PAGE = 20

  def show
    @media_type = params[:media_type].presence_in(%w[Vinyl CD]) || "Vinyl"
    @config = PickRandomConfig.current(@media_type)
    @vinyl_count = MediaItem.random_candidates("Vinyl").count
    @cd_count = MediaItem.random_candidates("CD").count
    @total_candidates = @media_type == "CD" ? @cd_count : @vinyl_count
    @candidates = MediaItem.random_candidates(@media_type).limit(PER_PAGE)
    @has_more = @total_candidates > PER_PAGE
    @inverse_total = MediaItem.recently_played_candidates(@media_type).count
    @inverse_candidates = MediaItem.recently_played_candidates(@media_type).limit(PER_PAGE)
  end

  def candidates
    @media_type = params[:media_type].presence_in(%w[Vinyl CD]) || "Vinyl"
    page = (params[:page] || 1).to_i
    all = MediaItem.random_candidates(@media_type)
    total = all.count
    @candidates = all.limit(PER_PAGE).offset(page * PER_PAGE)
    has_more = (page + 1) * PER_PAGE < total
    next_url = has_more ? candidates_pick_random_config_path(page: page + 1, media_type: @media_type) : ""
    response.set_header("X-Next-Page-Url", next_url)
    render partial: "candidate_items", layout: false
  end

  def edit
    @media_type = params[:media_type].presence_in(%w[Vinyl CD]) || "Vinyl"
    @config = PickRandomConfig.current(@media_type)
  end

  def update
    @media_type = params[:media_type].presence_in(%w[Vinyl CD]) || "Vinyl"
    @config = PickRandomConfig.current(@media_type)
    if @config.update(config_params)
      redirect_to pick_random_config_path(media_type: @media_type), notice: "Pick Random settings updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def config_params
    params.expect(pick_random_config: [
      :media_type,
      :last_played_days_ago,
      :play_count_operator,
      :play_count_threshold,
      :rating_filter
    ])
  end
end
