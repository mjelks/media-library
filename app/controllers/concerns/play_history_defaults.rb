module PlayHistoryDefaults
  extend ActiveSupport::Concern

  DEFAULT_PLAY_HISTORY_DAYS = (ENV["DAYS_AGO_PLAY_HISTORY"] || 7).to_i
end
