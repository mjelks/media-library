class SiteSettingsController < ApplicationController
  before_action :require_admin!

  def show
    @site_setting = SiteSetting.current
  end

  def edit
    @site_setting = SiteSetting.current
  end

  def update
    @site_setting = SiteSetting.current
    if @site_setting.update(site_setting_params)
      redirect_to site_setting_path, notice: "Site settings updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def site_setting_params
    params.expect(site_setting: [ :title, :subhead, :background_image ])
  end
end
