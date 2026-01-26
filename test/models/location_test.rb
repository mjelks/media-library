# == Schema Information
#
# Table name: locations
#
#  id            :integer          not null, primary key
#  cube_location :string
#  description   :text
#  name          :string           not null
#  position      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  media_type_id :integer
#
# Indexes
#
#  index_locations_on_media_type_id  (media_type_id)
#
# Foreign Keys
#
#  media_type_id  (media_type_id => media_types.id)
#
require "test_helper"

class LocationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
