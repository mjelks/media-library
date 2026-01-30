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
require "test_helper"

class MediaTypeTest < ActiveSupport::TestCase
  test "valid media type" do
    media_type = MediaType.new(name: "Cassette", description: "Cassette tapes")
    assert media_type.valid?
  end

  test "has many media_items" do
    media_type = media_types(:one)
    assert_respond_to media_type, :media_items
    assert_kind_of ActiveRecord::Associations::CollectionProxy, media_type.media_items
  end

  test "can access associated media items" do
    media_type = media_types(:vinyl)
    assert media_type.media_items.count >= 0
  end

  test "requires name" do
    media_type = MediaType.new(description: "Test description")
    assert_not media_type.valid?
    assert_includes media_type.errors[:name], "can't be blank"
  end

  test "allows nil description" do
    media_type = MediaType.new(name: "Test")
    assert media_type.valid?
  end
end
