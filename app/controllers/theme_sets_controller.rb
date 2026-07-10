class ThemeSetsController < ApplicationController
  before_action :require_admin!
  before_action :set_theme_set, only: %i[edit update destroy activate duplicate]

  def index
    @theme_sets = ThemeSet.order(:name)
    @theme_sets = [ ThemeSet.active ] if @theme_sets.empty?
  end

  def new
    prefill_attrs = ThemeSet::COLOR_ATTRIBUTES + %w[
      now_playing_card_border_radius
      color_scheme_mode color_scheme_hue color_scheme_saturation color_scheme_lightness
    ]
    @theme_set = ThemeSet.new(ThemeSet.active.attributes.slice(*prefill_attrs))
  end

  def create
    @theme_set = ThemeSet.new(theme_set_params)
    if @theme_set.save
      redirect_to theme_sets_path, notice: "Theme set \"#{@theme_set.name}\" created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @theme_set.update(theme_set_params)
      redirect_to theme_sets_path, notice: "Theme set \"#{@theme_set.name}\" updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @theme_set.destroy
      redirect_to theme_sets_path, status: :see_other, notice: "Theme set \"#{@theme_set.name}\" deleted."
    else
      redirect_to theme_sets_path, status: :see_other, alert: @theme_set.errors.full_messages.to_sentence
    end
  end

  def activate
    @theme_set.activate!
    redirect_to theme_sets_path, notice: "\"#{@theme_set.name}\" is now the active theme."
  end

  def duplicate
    copy = @theme_set.dup
    copy.name = unique_copy_name(@theme_set.name)
    copy.active = false

    if copy.save
      redirect_to theme_sets_path, notice: "Duplicated \"#{@theme_set.name}\" as \"#{copy.name}\"."
    else
      redirect_to theme_sets_path, status: :see_other, alert: copy.errors.full_messages.to_sentence
    end
  end

  private

  def unique_copy_name(base_name)
    candidate = "#{base_name} copy"
    suffix = 2
    while ThemeSet.exists?(name: candidate)
      candidate = "#{base_name} copy #{suffix}"
      suffix += 1
    end
    candidate
  end

  def set_theme_set
    @theme_set = ThemeSet.find(params.expect(:id))
  end

  def theme_set_params
    params.expect(theme_set: [
      :name, :now_playing_card_border_radius,
      :color_scheme_mode, :color_scheme_hue, :color_scheme_saturation, :color_scheme_lightness,
      *ThemeSet::COLOR_ATTRIBUTES
    ])
  end
end
