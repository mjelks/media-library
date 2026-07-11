require "test_helper"

# == Schema Information
#
# Table name: theme_sets
#
#  id         :integer          not null, primary key
#  active     :boolean          default(FALSE), not null
#  config     :json             not null
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_theme_sets_on_name  (name) UNIQUE
#
class ThemeSetTest < ActiveSupport::TestCase
  def valid_attributes(overrides = {})
    {
      name: "Some Theme",
      main_bg_color: "#a8a29e",
      nav_bg_color: "#1f2937",
      nav_font_color: "#ffffff",
      footer_bg_color: "#1f2937",
      footer_font_color: "#ffffff",
      h1_font_color: "#000000"
    }.merge(overrides)
  end

  # Validations
  test "valid with all required attributes" do
    assert theme_sets(:inactive_theme).valid?
  end

  test "requires a name" do
    theme_set = ThemeSet.new(valid_attributes(name: nil))
    assert_not theme_set.valid?
    assert_includes theme_set.errors[:name], "can't be blank"
  end

  test "requires a unique name" do
    theme_set = ThemeSet.new(valid_attributes(name: theme_sets(:active_theme).name))
    assert_not theme_set.valid?
    assert_includes theme_set.errors[:name], "has already been taken"
  end

  test "requires color attributes to be present" do
    theme_set = ThemeSet.new(valid_attributes(main_bg_color: nil))
    assert_not theme_set.valid?
    assert_includes theme_set.errors[:main_bg_color], "can't be blank"
  end

  test "rejects color attributes that aren't hex colors" do
    theme_set = ThemeSet.new(valid_attributes(main_bg_color: "blue"))
    assert_not theme_set.valid?
    assert_includes theme_set.errors[:main_bg_color], "must be a hex color like #a8a29e"
  end

  test "accepts a valid hex color for every color attribute" do
    theme_set = ThemeSet.new(valid_attributes)
    assert theme_set.valid?
  end

  test "requires now_playing_card_border_radius to be one of the allowed options" do
    theme_set = ThemeSet.new(valid_attributes(now_playing_card_border_radius: "3px"))
    assert_not theme_set.valid?
    assert_includes theme_set.errors[:now_playing_card_border_radius], "is not included in the list"
  end

  test "accepts any radius option" do
    ThemeSet::RADIUS_OPTIONS.each_value do |radius|
      theme_set = ThemeSet.new(valid_attributes(name: "Radius #{radius}", now_playing_card_border_radius: radius))
      assert theme_set.valid?, "expected #{radius.inspect} to be valid"
    end
  end

  # .active
  test "active returns the active theme set when one exists" do
    assert_equal theme_sets(:active_theme), ThemeSet.active
  end

  test "active creates and returns a default theme set when none is active" do
    ThemeSet.update_all(active: false)

    theme_set = ThemeSet.active

    assert theme_set.persisted?
    assert theme_set.active?
    assert_equal ThemeSet::DEFAULT_NAME, theme_set.name
    assert_equal ThemeSet::DEFAULT_RADIUS, theme_set.now_playing_card_border_radius
    ThemeSet::DEFAULT_COLORS.each do |attr, value|
      assert_equal value, theme_set.public_send(attr)
    end
  end

  # activate!
  test "activate! makes the theme set active and deactivates all others" do
    theme_set = theme_sets(:inactive_theme)

    theme_set.activate!

    assert theme_set.reload.active?
    assert_not theme_sets(:active_theme).reload.active?
  end

  test "activate! is idempotent when already active" do
    theme_set = theme_sets(:active_theme)

    assert_nothing_raised { theme_set.activate! }
    assert theme_set.reload.active?
  end

  # before_destroy :ensure_not_active
  test "cannot destroy the active theme set" do
    theme_set = theme_sets(:active_theme)

    assert_not theme_set.destroy
    assert_includes theme_set.errors[:base], "Can't delete the active theme set"
    assert ThemeSet.exists?(theme_set.id)
  end

  test "can destroy an inactive theme set" do
    theme_set = theme_sets(:inactive_theme)

    assert theme_set.destroy
    assert_not ThemeSet.exists?(theme_set.id)
  end
end
