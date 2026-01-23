# == Schema Information
#
# Table name: media_owners
#
#  id          :integer          not null, primary key
#  description :text
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class MediaOwner < ApplicationRecord
  has_many :media_items
end
