module PlaySessionsHelper
  # Segmented List / Calendar view switcher shown left of "Back to Now
  # Playing" on these pages. Styled to match the Vinyl | CD toggle on the Now
  # Playing homepage. Both tabs point at `month` (defaulting to the current
  # month) so switching between them keeps whatever month is under
  # retrospection.
  def play_history_view_toggle(active:, month: Date.current.beginning_of_month)
    content_tag :div, class: "flex rounded-lg overflow-hidden border border-gray-300" do
      concat link_to(list_icon_svg, play_sessions_month_path(year: month.year, month: month.month),
          class: toggle_tab_classes(active == :list), title: "List view",
          data: { "play-calendar-target": "listLink" })

      concat link_to(calendar_icon_svg, play_sessions_calendar_path(year: month.year, month: month.month),
          class: toggle_tab_classes(active == :calendar), title: "Calendar view",
          data: { "play-calendar-target": "calendarLink" })
    end
  end

  def toggle_tab_classes(is_active)
    "px-4 py-2.5 font-medium text-sm transition-colors flex items-center #{is_active ? 'themed-toggle-active' : 'themed-btn-secondary'}"
  end

  # Bulleted list icon — distinct from the plain hamburger bars used for the
  # mobile nav toggle elsewhere, so it doesn't imply "open a menu".
  def list_icon_svg(classes: "w-5 h-5")
    content_tag :svg, class: classes, fill: "none", stroke: "currentColor", viewBox: "0 0 24 24" do
      tag.path(
        "stroke-linecap": "round",
        "stroke-linejoin": "round",
        "stroke-width": "2",
        d: "M8.25 6.75h12M8.25 12h12M8.25 17.25h12M3.75 6.75h.007v.008H3.75V6.75Zm.375 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0ZM3.75 12h.007v.008H3.75V12Zm.375 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Zm-.375 5.25h.007v.008H3.75v-.008Zm.375 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Z"
      )
    end
  end

  def calendar_icon_svg(classes: "w-5 h-5")
    content_tag :svg, class: classes, fill: "none", stroke: "currentColor", viewBox: "0 0 24 24" do
      tag.path(
        "stroke-linecap": "round",
        "stroke-linejoin": "round",
        "stroke-width": "2",
        d: "M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
      )
    end
  end

  def chevron_left_icon(classes: "w-5 h-5")
    content_tag :svg, class: classes, fill: "none", stroke: "currentColor", viewBox: "0 0 24 24" do
      tag.path("stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M15 19l-7-7 7-7")
    end
  end

  def chevron_right_icon(classes: "w-5 h-5")
    content_tag :svg, class: classes, fill: "none", stroke: "currentColor", viewBox: "0 0 24 24" do
      tag.path("stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M9 5l7 7-7 7")
    end
  end
end
