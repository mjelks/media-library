class ThemeSetsController < ApplicationController
  before_action :require_admin!
  before_action :set_theme_set, only: %i[edit update destroy activate]

  def index
    @theme_sets = ThemeSet.order(:name)
    @theme_sets = [ ThemeSet.active ] if @theme_sets.empty?
  end

  def new
    @theme_set = ThemeSet.new(ThemeSet.active.attributes.slice(*ThemeSet::COLOR_ATTRIBUTES))
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

  private

  def set_theme_set
    @theme_set = ThemeSet.find(params.expect(:id))
  end

  def theme_set_params
    params.expect(theme_set: [ :name, *ThemeSet::COLOR_ATTRIBUTES ])
  end
end
