# == Schema Information
#
# Table name: locations
#
#  id            :integer          not null, primary key
#  description   :text
#  name          :string           not null
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
class Location < ApplicationRecord
  has_many :media_items
  belongs_to :media_type, optional: true
end
