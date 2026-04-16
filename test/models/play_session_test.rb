require "test_helper"

class PlaySessionTest < ActiveSupport::TestCase
  # recent scope

  test "recent includes sessions within the given window" do
    assert_includes PlaySession.recent(7), play_sessions(:recent_session)
  end

  test "recent includes open sessions within the window" do
    assert_includes PlaySession.recent(7), play_sessions(:now_playing_session)
  end

  test "recent excludes sessions older than the window" do
    assert_not_includes PlaySession.recent(7), play_sessions(:old_session)
  end

  test "recent includes sessions at a wider window" do
    assert_includes PlaySession.recent(31), play_sessions(:old_session)
  end

  test "recent orders by start_time descending" do
    ordered = PlaySession.recent(31).to_a
    assert_equal ordered, ordered.sort_by(&:start_time).reverse
  end

  # all_history scope

  test "all_history includes completed sessions" do
    assert_includes PlaySession.all_history, play_sessions(:recent_session)
    assert_includes PlaySession.all_history, play_sessions(:old_session)
  end

  test "all_history excludes open session for currently-playing item" do
    assert_not_includes PlaySession.all_history, play_sessions(:now_playing_session)
  end

  test "all_history includes session with no end_time when item is not currently playing" do
    session = play_sessions(:recent_session)
    session.update!(end_time: nil)
    assert_includes PlaySession.all_history, session
  end

  test "all_history returns sessions regardless of age" do
    results = PlaySession.all_history
    assert_includes results, play_sessions(:recent_session)
    assert_includes results, play_sessions(:old_session)
  end

  test "all_history orders by start_time descending" do
    ordered = PlaySession.all_history.to_a
    assert_equal ordered, ordered.sort_by(&:start_time).reverse
  end
end
