class LocationsController < ApplicationController
  before_action :set_location, only: %i[ show edit update destroy ]

  # GET /locations
  def index
    redirect_to vinyl_locations_path
  end

  # GET /locations/vinyl
  def vinyl
    @media_type = "Vinyl"
    @locations = Location.vinyl.order(:position, :name)
    @total = @locations.count
    render :index
  end

  # GET /locations/cd
  def cd
    @media_type = "CD"
    @locations = Location.cd.order(:position, :name)
    @total = @locations.count
    render :index
  end

  # PATCH /locations/reorder
  def reorder
    location_ids = params[:location_ids]
    if location_ids.present?
      location_ids.each_with_index do |id, index|
        Location.where(id: id).update_all(position: index + 1)
      end
      head :ok
    else
      head :unprocessable_entity
    end
  end

  # GET /locations/1 or /locations/1.json
  def show
  end

  # GET /locations/new
  def new
    @location = Location.new
    @media_types = MediaType.order(:name)
  end

  # GET /locations/1/edit
  def edit
    @media_types = MediaType.order(:name)
  end

  # POST /locations or /locations.json
  def create
    @location = Location.new(location_params)

    respond_to do |format|
      if @location.save
        format.html { redirect_to @location, notice: "Location was successfully created." }
        format.json { render :show, status: :created, location: @location }
      else
        @media_types = MediaType.order(:name)
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /locations/1 or /locations/1.json
  def update
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to @location, notice: "Location was successfully updated." }
        format.json { render :show, status: :ok, location: @location }
      else
        @media_types = MediaType.order(:name)
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1 or /locations/1.json
  def destroy
    @location.destroy!

    respond_to do |format|
      format.html { redirect_to locations_path, status: :see_other, notice: "Location was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def location_params
      params.expect(location: [ :name, :description, :media_type_id, :cube_location, :position ])
    end
end
