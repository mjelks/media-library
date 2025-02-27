class MediaItemsController < ApplicationController
  def index
    @media_items = MediaItem.order(Arel.sql("LOWER(title)"))
  end

  def show
    @media_item = MediaItem.find(params[:id])
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
