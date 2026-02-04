require "test_helper"

class CdCollectionHelperTest < ActionView::TestCase
  include CdCollectionHelper

  # slot_label_for tests
  test "slot_label_for returns dash for nil" do
    assert_equal "—", slot_label_for(nil)
  end

  test "slot_label_for returns dash for zero" do
    assert_equal "—", slot_label_for(0)
  end

  test "slot_label_for returns dash for negative" do
    assert_equal "—", slot_label_for(-1)
  end

  test "slot_label_for returns 1A for position 1" do
    assert_equal "1A", slot_label_for(1)
  end

  test "slot_label_for returns 1B for position 2" do
    assert_equal "1B", slot_label_for(2)
  end

  test "slot_label_for returns 1C for position 3" do
    assert_equal "1C", slot_label_for(3)
  end

  test "slot_label_for returns 1D for position 4" do
    assert_equal "1D", slot_label_for(4)
  end

  test "slot_label_for returns 1E for position 5 (side B)" do
    assert_equal "1E", slot_label_for(5)
  end

  test "slot_label_for returns 1F for position 6" do
    assert_equal "1F", slot_label_for(6)
  end

  test "slot_label_for returns 1G for position 7" do
    assert_equal "1G", slot_label_for(7)
  end

  test "slot_label_for returns 1H for position 8" do
    assert_equal "1H", slot_label_for(8)
  end

  test "slot_label_for returns 2A for position 9 (page 2)" do
    assert_equal "2A", slot_label_for(9)
  end

  test "slot_label_for returns 2E for position 13 (page 2 side B)" do
    assert_equal "2E", slot_label_for(13)
  end

  test "slot_label_for returns 3A for position 17 (page 3)" do
    assert_equal "3A", slot_label_for(17)
  end

  # slot_position_for tests
  test "slot_position_for returns 1 for page 1 side A slot 0" do
    assert_equal 1, slot_position_for(1, "A", 0)
  end

  test "slot_position_for returns 4 for page 1 side A slot 3" do
    assert_equal 4, slot_position_for(1, "A", 3)
  end

  test "slot_position_for returns 5 for page 1 side B slot 0" do
    assert_equal 5, slot_position_for(1, "B", 0)
  end

  test "slot_position_for returns 8 for page 1 side B slot 3" do
    assert_equal 8, slot_position_for(1, "B", 3)
  end

  test "slot_position_for returns 9 for page 2 side A slot 0" do
    assert_equal 9, slot_position_for(2, "A", 0)
  end

  test "slot_position_for returns 13 for page 2 side B slot 0" do
    assert_equal 13, slot_position_for(2, "B", 0)
  end

  # page_and_side_for tests
  test "page_and_side_for returns page 1 side A for position 1" do
    result = page_and_side_for(1)
    assert_equal 1, result[:page]
    assert_equal "A", result[:side]
  end

  test "page_and_side_for returns page 1 side A for position 4" do
    result = page_and_side_for(4)
    assert_equal 1, result[:page]
    assert_equal "A", result[:side]
  end

  test "page_and_side_for returns page 1 side B for position 5" do
    result = page_and_side_for(5)
    assert_equal 1, result[:page]
    assert_equal "B", result[:side]
  end

  test "page_and_side_for returns page 1 side B for position 8" do
    result = page_and_side_for(8)
    assert_equal 1, result[:page]
    assert_equal "B", result[:side]
  end

  test "page_and_side_for returns page 2 side A for position 9" do
    result = page_and_side_for(9)
    assert_equal 2, result[:page]
    assert_equal "A", result[:side]
  end

  test "page_and_side_for returns page 2 side B for position 13" do
    result = page_and_side_for(13)
    assert_equal 2, result[:page]
    assert_equal "B", result[:side]
  end

  test "page_and_side_for returns page 25 side B for position 200" do
    result = page_and_side_for(200)
    assert_equal 25, result[:page]
    assert_equal "B", result[:side]
  end

  test "slot_position_for and slot_label_for are inverse operations" do
    # Test a range of positions
    (1..50).each do |pos|
      label = slot_label_for(pos)
      page = label[0..-2].to_i
      letter = label[-1]

      if %w[A B C D].include?(letter)
        side = "A"
        slot_idx = %w[A B C D].index(letter)
      else
        side = "B"
        slot_idx = %w[E F G H].index(letter)
      end

      assert_equal pos, slot_position_for(page, side, slot_idx), "Failed for position #{pos}"
    end
  end
end
