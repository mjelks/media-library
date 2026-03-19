class LpCartridgesController < ApplicationController
  before_action :set_lp_cartridge, only: %i[show edit update destroy]

  def index
    @lp_cartridges = LpCartridge.ordered
  end

  def show
  end

  def new
    @lp_cartridge = LpCartridge.new(installed_at: Date.today)
  end

  def edit
  end

  def create
    @lp_cartridge = LpCartridge.new(lp_cartridge_params)

    if @lp_cartridge.save
      redirect_to lp_cartridges_path, notice: "Cartridge was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @lp_cartridge.update(lp_cartridge_params)
      redirect_to lp_cartridges_path, notice: "Cartridge was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @lp_cartridge.destroy!
    redirect_to lp_cartridges_path, status: :see_other, notice: "Cartridge was successfully deleted."
  end

  private

  def set_lp_cartridge
    @lp_cartridge = LpCartridge.find(params[:id])
  end

  def lp_cartridge_params
    params.expect(lp_cartridge: [ :name, :installed_at, :usage_limit, :notes ])
  end
end
