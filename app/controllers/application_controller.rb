class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  around_action :set_user_timezone

  private

  def set_user_timezone
    timezone = Current.user&.timezone.presence || "America/Los_Angeles"
    Time.use_zone(timezone) { yield }
  end
end
