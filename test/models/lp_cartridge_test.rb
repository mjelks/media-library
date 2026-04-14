# == Schema Information
#
# Table name: lp_cartridges
#
#  id           :integer          not null, primary key
#  installed_at :date             not null
#  name         :string           not null
#  notes        :text
#  usage_limit  :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require "test_helper"

class LpCartridgeTest < ActiveSupport::TestCase
  # release :one tracks: 4:32 + 3:58 = 272 + 238 = 510 seconds
  # release :two tracks: 6:12 + 4:29 = 372 + 269 = 641 seconds
  #
  # current_cartridge installed 3 days ago captures:
  #   vinyl_now_playing  (10 min ago, release :one) → 510s
  #   vinyl_recently_played (2 days ago, release :two) → 641s
  #   total = 1151 seconds
  EXPECTED_USED_SECONDS = 1151

  # Validations

  test "valid with name and installed_at" do
    cartridge = LpCartridge.new(name: "Test Cartridge", installed_at: Date.today)
    assert cartridge.valid?
  end

  test "requires name" do
    cartridge = LpCartridge.new(installed_at: Date.today)
    assert_not cartridge.valid?
    assert_includes cartridge.errors[:name], "can't be blank"
  end

  test "requires installed_at" do
    cartridge = LpCartridge.new(name: "Test Cartridge")
    assert_not cartridge.valid?
    assert_includes cartridge.errors[:installed_at], "can't be blank"
  end

  # .current

  test ".current returns the most recently installed cartridge" do
    assert_equal lp_cartridges(:current_cartridge), LpCartridge.current
  end

  test ".current returns nil when no cartridges exist" do
    LpCartridge.delete_all
    assert_nil LpCartridge.current
  end

  # hours_used_in_seconds

  test "hours_used_in_seconds sums duration of vinyl items played since install date" do
    cartridge = lp_cartridges(:current_cartridge)
    assert_equal EXPECTED_USED_SECONDS, cartridge.hours_used_in_seconds
  end

  test "hours_used_in_seconds excludes vinyl played before install date" do
    # old_cartridge was installed 60 days ago, vinyl_played_long_ago was 30 days ago — included
    # current_cartridge installed 3 days ago, vinyl_played_long_ago excluded
    current = lp_cartridges(:current_cartridge)
    old     = lp_cartridges(:old_cartridge)
    assert old.hours_used_in_seconds > current.hours_used_in_seconds
  end

  test "hours_used_in_seconds excludes non-vinyl media items" do
    cartridge = lp_cartridges(:current_cartridge)
    # media_items :one and :two are CD/Album types — should not be counted
    used = cartridge.hours_used_in_seconds
    assert_equal EXPECTED_USED_SECONDS, used
  end

  test "hours_used_in_seconds returns 0 when no vinyl played since install" do
    future_cartridge = LpCartridge.new(name: "Future", installed_at: Date.tomorrow)
    assert_equal 0, future_cartridge.hours_used_in_seconds
  end

  # hours_remaining

  test "hours_remaining returns nil when usage_limit is nil" do
    cartridge = lp_cartridges(:no_limit_cartridge)
    assert_nil cartridge.hours_remaining
  end

  test "hours_remaining floors to nearest quarter hour" do
    cartridge = lp_cartridges(:current_cartridge)
    # limit: 10h = 36000s, used: 1151s, remaining: 34849s
    # 34849 / 3600.0 * 4 = 38.72... → floor → 38 → 38 / 4.0 = 9.5
    assert_equal 9.5, cartridge.hours_remaining
  end

  test "hours_remaining accepts pre-computed used_seconds to avoid double query" do
    cartridge = lp_cartridges(:current_cartridge)
    assert_equal cartridge.hours_remaining(EXPECTED_USED_SECONDS),
                 cartridge.hours_remaining
  end

  test "hours_remaining never returns negative" do
    cartridge = lp_cartridges(:current_cartridge)
    cartridge.usage_limit = 0
    assert_equal 0.0, cartridge.hours_remaining
  end

  test "hours_remaining returns a quarter-hour increment" do
    cartridge = lp_cartridges(:current_cartridge)
    result = cartridge.hours_remaining
    assert_equal 0, (result * 4) % 1, "Expected result to be a multiple of 0.25, got #{result}"
  end
end
