# == Schema Information
#
# Table name: media_types
#
#  id          :integer          not null, primary key
#  description :text
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class MediaType < ApplicationRecord
  has_many :media_items
end
