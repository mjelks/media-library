# == Schema Information
#
# Table name: site_settings
#
#  id         :integer          not null, primary key
#  subhead    :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class SiteSetting < ApplicationRecord
  has_one_attached :background_image

  DEFAULT_TITLE = "Bicyclelad's Music Collection".freeze
  DEFAULT_SUBHEAD = "What's on tap at Bicyclelad's House".freeze

  def self.current
    first_or_create!(title: DEFAULT_TITLE, subhead: DEFAULT_SUBHEAD)
  end
end
