class DiscogsController < ApplicationController
  allow_unauthenticated_access

  def index
    @query = params[:q]
    @type_filter = params[:type]
    @results = []

    if @query.present?
      begin
        discogs = Discogs.new
        search_options = {}
        search_options[:type] = @type_filter if @type_filter.present?
        search_options[:per_page] = 50

        response = discogs.search(@query, search_options)

        if response["error"]
          flash.now[:alert] = "Error searching Discogs: #{response["message"]}"
        else
          @results = response["results"] || []
          @pagination = response["pagination"] || {}
        end
      rescue StandardError => e
        flash.now[:alert] = "An error occurred: #{e.message}"
      end
    end
  end

  def show
    @release_id = params[:id]

    begin
      discogs = Discogs.new
      @release = discogs.get_release(@release_id)

      if @release["error"]
        flash[:alert] = "Error fetching release: #{@release["message"]}"
        redirect_to discogs_path
      end
    rescue StandardError => e
      flash[:alert] = "An error occurred: #{e.message}"
      redirect_to discogs_path
    end
  end
end
