class MediaOwnersController < ApplicationController
  before_action :set_media_owner, only: %i[ show edit update destroy ]

  # GET /media_owners or /media_owners.json
  def index
    @media_owners = MediaOwner.order(Arel.sql("LOWER(name)"))
  end

  # GET /media_owners/1 or /media_owners/1.json
  def show
  end

  # GET /media_owners/new
  def new
    @media_owner = MediaOwner.new
  end

  # GET /media_owners/1/edit
  def edit
  end

  # POST /media_owners or /media_owners.json
  def create
    @media_owner = MediaOwner.new(media_owner_params)

    respond_to do |format|
      if @media_owner.save
        format.html { redirect_to @media_owner, notice: "Media owner was successfully created." }
        format.json { render :show, status: :created, location: @media_owner }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @media_owner.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /media_owners/1 or /media_owners/1.json
  def update
    respond_to do |format|
      if @media_owner.update(media_owner_params)
        format.html { redirect_to @media_owner, notice: "Media owner was successfully updated." }
        format.json { render :show, status: :ok, location: @media_owner }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @media_owner.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /media_owners/1 or /media_owners/1.json
  def destroy
    @media_owner.destroy!

    respond_to do |format|
      format.html { redirect_to media_owners_path, status: :see_other, notice: "Media owner was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_media_owner
      @media_owner = MediaOwner.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def media_owner_params
      params.expect(media_owner: [ :name, :description ])
    end
end
