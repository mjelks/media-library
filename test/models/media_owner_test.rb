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
require "test_helper"

class MediaOwnerTest < ActiveSupport::TestCase
  test "valid media owner" do
    media_owner = MediaOwner.new(name: "The Beatles", description: "British rock band")
    assert media_owner.valid?
  end

  test "has many releases" do
    media_owner = media_owners(:one)
    assert_respond_to media_owner, :releases
    assert_kind_of ActiveRecord::Associations::CollectionProxy, media_owner.releases
  end

  test "has many media_items through releases" do
    media_owner = media_owners(:one)
    assert_respond_to media_owner, :media_items
    assert_kind_of ActiveRecord::Associations::CollectionProxy, media_owner.media_items
  end

  test "can access releases" do
    media_owner = media_owners(:one)
    assert media_owner.releases.any?
    assert_kind_of Release, media_owner.releases.first
  end

  test "can access media_items through releases" do
    media_owner = media_owners(:one)
    assert media_owner.media_items.count >= 0
  end

  test "requires name" do
    media_owner = MediaOwner.new(description: "Test description")
    assert_not media_owner.valid?
    assert_includes media_owner.errors[:name], "can't be blank"
  end

  test "allows nil description" do
    media_owner = MediaOwner.new(name: "Test Artist")
    assert media_owner.valid?
  end
end
