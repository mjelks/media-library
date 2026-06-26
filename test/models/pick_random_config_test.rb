require "test_helper"

class PickRandomConfigTest < ActiveSupport::TestCase
  # Validations
  test "valid with all required attributes" do
    assert pick_random_configs(:vinyl).valid?
  end

  test "requires last_played_days_ago greater than 0" do
    config = pick_random_configs(:vinyl)
    config.last_played_days_ago = 0
    assert_not config.valid?
    assert_includes config.errors[:last_played_days_ago], "must be greater than 0"
  end

  test "requires last_played_days_ago to be an integer" do
    config = pick_random_configs(:vinyl)
    config.last_played_days_ago = 1.5
    assert_not config.valid?
  end

  test "requires play_count_operator to be a valid value" do
    config = pick_random_configs(:vinyl)
    config.play_count_operator = "invalid"
    assert_not config.valid?
    assert_includes config.errors[:play_count_operator], "is not included in the list"
  end

  test "accepts all valid play_count_operators" do
    config = pick_random_configs(:vinyl)
    %w[none less_than greater_than].each do |op|
      config.play_count_operator = op
      assert config.valid?, "Expected #{op} to be valid"
    end
  end

  test "requires rating_filter to be a valid value" do
    config = pick_random_configs(:vinyl)
    config.rating_filter = "invalid"
    assert_not config.valid?
    assert_includes config.errors[:rating_filter], "is not included in the list"
  end

  test "accepts all valid rating_filters" do
    config = pick_random_configs(:vinyl)
    %w[none exclude_meh prefer_thumbs_up].each do |filter|
      config.rating_filter = filter
      assert config.valid?, "Expected #{filter} to be valid"
    end
  end

  test "requires play_count_threshold to be non-negative when present" do
    config = pick_random_configs(:vinyl)
    config.play_count_threshold = -1
    assert_not config.valid?
    assert_includes config.errors[:play_count_threshold], "must be greater than or equal to 0"
  end

  test "allows nil play_count_threshold" do
    config = pick_random_configs(:vinyl)
    config.play_count_threshold = nil
    assert config.valid?
  end

  test "requires media_type to be Vinyl or CD" do
    config = pick_random_configs(:vinyl)
    config.media_type = "Cassette"
    assert_not config.valid?
    assert_includes config.errors[:media_type], "is not included in the list"
  end

  test "enforces uniqueness of media_type" do
    duplicate = PickRandomConfig.new(
      media_type: "Vinyl",
      last_played_days_ago: 30,
      play_count_operator: "none",
      rating_filter: "none"
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:media_type], "has already been taken"
  end

  # .current
  test "current returns existing record for given media type" do
    config = PickRandomConfig.current("Vinyl")
    assert_equal pick_random_configs(:vinyl).id, config.id
  end

  test "current returns separate records for Vinyl and CD" do
    vinyl = PickRandomConfig.current("Vinyl")
    cd    = PickRandomConfig.current("CD")
    assert_not_equal vinyl.id, cd.id
    assert_equal "Vinyl", vinyl.media_type
    assert_equal "CD", cd.media_type
  end

  test "current creates a record with defaults when none exists" do
    PickRandomConfig.delete_all
    config = PickRandomConfig.current("Vinyl")
    assert_equal "Vinyl", config.media_type
    assert_equal 60, config.last_played_days_ago
    assert_equal "none", config.play_count_operator
    assert_nil config.play_count_threshold
    assert_equal "none", config.rating_filter
  end

  test "current defaults to Vinyl when no argument given" do
    config = PickRandomConfig.current
    assert_equal "Vinyl", config.media_type
  end

  test "current does not create duplicate records on repeated calls" do
    PickRandomConfig.current("Vinyl")
    assert_no_difference "PickRandomConfig.count" do
      PickRandomConfig.current("Vinyl")
    end
  end

  # #play_count_active?
  test "play_count_active? is false when operator is none" do
    config = pick_random_configs(:vinyl)
    config.play_count_operator = "none"
    config.play_count_threshold = 5
    assert_not config.play_count_active?
  end

  test "play_count_active? is false when threshold is nil" do
    config = pick_random_configs(:vinyl)
    config.play_count_operator = "less_than"
    config.play_count_threshold = nil
    assert_not config.play_count_active?
  end

  test "play_count_active? is true when operator is set and threshold is present" do
    config = pick_random_configs(:vinyl)
    config.play_count_operator = "less_than"
    config.play_count_threshold = 3
    assert config.play_count_active?
  end

  # #rating_filter_active?
  test "rating_filter_active? is false when filter is none" do
    config = pick_random_configs(:vinyl)
    config.rating_filter = "none"
    assert_not config.rating_filter_active?
  end

  test "rating_filter_active? is true when filter is exclude_meh" do
    config = pick_random_configs(:vinyl)
    config.rating_filter = "exclude_meh"
    assert config.rating_filter_active?
  end

  test "rating_filter_active? is true when filter is prefer_thumbs_up" do
    config = pick_random_configs(:vinyl)
    config.rating_filter = "prefer_thumbs_up"
    assert config.rating_filter_active?
  end

  # #description
  test "description includes last played days" do
    config = pick_random_configs(:vinyl)
    assert_includes config.description, "not played in the last 60 days"
  end

  test "description includes play count clause when active" do
    config = pick_random_configs(:vinyl)
    config.play_count_operator = "less_than"
    config.play_count_threshold = 3
    assert_includes config.description, "play count less than 3"
  end

  test "description includes greater than play count clause" do
    config = pick_random_configs(:vinyl)
    config.play_count_operator = "greater_than"
    config.play_count_threshold = 10
    assert_includes config.description, "play count greater than 10"
  end

  test "description omits play count clause when inactive" do
    config = pick_random_configs(:vinyl)
    config.play_count_operator = "none"
    assert_not_includes config.description, "play count"
  end

  test "description includes exclude_meh clause" do
    config = pick_random_configs(:vinyl)
    config.rating_filter = "exclude_meh"
    assert_includes config.description, "excluding meh'd releases"
  end

  test "description includes prefer_thumbs_up clause" do
    config = pick_random_configs(:vinyl)
    config.rating_filter = "prefer_thumbs_up"
    assert_includes config.description, "thumbs-up releases only"
  end

  test "description omits rating clause when filter is none" do
    config = pick_random_configs(:vinyl)
    config.rating_filter = "none"
    assert_not_includes config.description, "meh"
    assert_not_includes config.description, "thumbs"
  end
end
