# == Schema Information
#
# Table name: media_items
#
#  id            :integer          not null, primary key
#  item_count    :integer          default(1), not null
#  notes         :text
#  play_count    :integer
#  position      :integer
#  year          :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  location_id   :integer
#  media_type_id :integer          not null
#  release_id    :integer
#
# Indexes
#
#  index_media_items_on_location_id               (location_id)
#  index_media_items_on_location_id_and_position  (location_id,position)
#  index_media_items_on_media_type_id             (media_type_id)
#  index_media_items_on_release_id                (release_id)
#  index_media_items_on_year                      (year)
#
# Foreign Keys
#
#  location_id    (location_id => locations.id)
#  media_type_id  (media_type_id => media_types.id)
#  release_id     (release_id => releases.id)
#
require "test_helper"

class MediaItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
