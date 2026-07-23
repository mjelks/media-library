module ApplicationHelper
  # Color palette for location dividers (record-themed colors)
  LOCATION_COLORS = [
    "#dc2626", # red
    "#ea580c", # orange
    "#ca8a04", # yellow
    "#16a34a", # green
    "#0891b2", # cyan
    "#2563eb", # blue
    "#7c3aed", # violet
    "#db2777", # pink
    "#854d0e", # brown
    "#475569"  # slate
  ].freeze

  def location_color(location)
    LOCATION_COLORS[location.id % LOCATION_COLORS.length]
  end

  # Memoized per request so hover popups can check queue state without N+1s
  def queued_media_item_ids
    @_queued_media_item_ids ||= Playlist.active.pluck(:media_item_id).to_set
  end

  def location_color_dark(location)
    color = location_color(location)
    darken_color(color, 30)
  end

  # Spine colors for record collection - vinyl-like colors
  SPINE_COLORS = [
    "#1a1a1a", # black vinyl
    "#2d2d2d", # dark gray
    "#3d3d3d", # charcoal
    "#4a3728", # dark brown
    "#5c3d2e", # brown
    "#2c1810", # dark walnut
    "#1e3a5f", # navy
    "#3d1c02", # chocolate
    "#0d0d0d", # near black
    "#4b4b4b", # medium gray
    "#6b3a3a", # burgundy
    "#2f4f2f", # dark green
    "#3b3b5c", # dark purple
    "#5c4033", # saddle brown
    "#1c1c1c"  # off black
  ].freeze

  def spine_color_for_media_item(media_item, _index = nil)
    # Use artist ID/name as seed so same artist = same color
    artist_id = media_item.media_owner&.id || media_item.media_owner&.name&.hash || 0
    SPINE_COLORS[artist_id.abs % SPINE_COLORS.length]
  end

  def darken_color(hex_color, percent)
    amount = percent / 100.0
    hex = hex_color.gsub("#", "")
    r = [ (hex[0..1].to_i(16) * (1 - amount)).to_i, 0 ].max
    g = [ (hex[2..3].to_i(16) * (1 - amount)).to_i, 0 ].max
    b = [ (hex[4..5].to_i(16) * (1 - amount)).to_i, 0 ].max
    "#%02x%02x%02x" % [ r, g, b ]
  end

  def lighten_color(hex_color, percent)
    amount = percent / 100.0
    hex = hex_color.gsub("#", "")
    r = [ (hex[0..1].to_i(16) + ((255 - hex[0..1].to_i(16)) * amount)).to_i, 255 ].min
    g = [ (hex[2..3].to_i(16) + ((255 - hex[2..3].to_i(16)) * amount)).to_i, 255 ].min
    b = [ (hex[4..5].to_i(16) + ((255 - hex[4..5].to_i(16)) * amount)).to_i, 255 ].min
    "#%02x%02x%02x" % [ r, g, b ]
  end

  def theme_style_vars(theme_set)
    vars = ThemeSet::COLOR_ATTRIBUTES.map do |attr|
      "--theme-#{attr.delete_suffix('_color').tr('_', '-')}: #{theme_set.public_send(attr)};"
    end
    vars << "--theme-now-playing-card-radius: #{theme_set.now_playing_card_border_radius};"
    vars.join(" ")
  end

  # Album count bubble for the Listening Stats widget. Shows a plain "Albums"
  # tooltip when no LP/CD breakdown is available, otherwise a per-media-type
  # breakdown via the tooltip Stimulus controller.
  def album_stat_bubble(count, tooltip_lines = [])
    attrs = if tooltip_lines.any?
      { data: {
        controller: "tooltip",
        tooltip_text_value: tooltip_lines.join("\n"),
        action: "mouseenter->tooltip#show mouseleave->tooltip#hide"
      } }
    else
      { title: "Albums" }
    end

    content_tag :span, **attrs, class: "relative inline-flex items-center justify-center w-16 h-16 bg-gray-800 rounded-full align-middle" do
      concat content_tag(:span, "", class: "w-6 h-6 bg-[#eee] rounded-full")
      concat content_tag(:span, count, class: "absolute inset-0 flex items-center justify-center text-xs font-bold text-black")
    end
  end

  # Media type badge shown next to play history rows: a skeuomorphic vinyl
  # disc for LPs, the CD emoji for CDs. `size` takes Tailwind width/height
  # classes (e.g. "w-5 h-5"); the label and spindle inside the disc are sized
  # in percentages so they scale with it without needing new Tailwind classes.
  # `opacity` takes a Tailwind opacity scale value (e.g. 70 for "opacity-70").
  # Mapped through a literal lookup (rather than interpolated directly) so
  # Tailwind's content scanner, which matches literal text rather than
  # evaluating Ruby, can see each class name and generate it.
  OPACITY_CLASSES = {
    0 => "opacity-0", 5 => "opacity-5", 10 => "opacity-10", 20 => "opacity-20",
    25 => "opacity-25", 30 => "opacity-30", 40 => "opacity-40", 50 => "opacity-50",
    60 => "opacity-60", 70 => "opacity-70", 75 => "opacity-75", 80 => "opacity-80",
    90 => "opacity-90", 95 => "opacity-95", 100 => "opacity-100"
  }.freeze

  # The CD icon is a text glyph, not a box with width/height, so its `size`
  # (the same Tailwind w-*/h-* pair passed for the Vinyl icon) is mapped to a
  # font-size class that renders at roughly the same visual size.
  SIZE_FONT_CLASSES = {
    "w-4 h-4" => "text-sm",
    "w-5 h-5" => "text-lg",
    "w-6 h-6" => "text-xl"
  }.freeze

  def media_type_icon(media_type_name, size: "w-5 h-5", opacity: nil)
    opacity_class = opacity ? " #{OPACITY_CLASSES.fetch(opacity)}" : ""
    if media_type_name == "CD"
      font_class = SIZE_FONT_CLASSES.fetch(size, "text-lg")
      content_tag :span, "💿", title: "CD", class: "#{font_class} align-middle#{opacity_class}"
    else
      content_tag :span, title: "Vinyl",
        class: "inline-flex items-center justify-center #{size} rounded-full align-middle#{opacity_class}",
        style: "background-image: repeating-radial-gradient(circle at center, #2a2a2a 0px, #2a2a2a 1px, #161616 1.5px, #161616 2px);" do
        content_tag :span, class: "flex items-center justify-center rounded-full bg-[#eee]", style: "width: 33%; height: 33%;" do
          content_tag :span, "", class: "rounded-full bg-gray-900", style: "width: 40%; height: 40%;"
        end
      end
    end
  end

  def quarter_hours(total_seconds)
    return nil if total_seconds.nil?
    (total_seconds / 3600.0 * 4).round / 4.0
  end

  def duration_font_size_class(total_seconds)
    total_seconds.to_i >= 86400 ? "text-m" : "text-2xl"
  end

  # Unlike duration_formatter, hours are never rolled over into days —
  # e.g. 247:23:23 rather than "10 Days, 7 Hours, 23 Minutes".
  def duration_hms(total_seconds)
    return "-" if total_seconds.nil?

    hours, remainder = total_seconds.divmod(3600)
    minutes, seconds = remainder.divmod(60)
    format("%d:%02d:%02d", hours, minutes, seconds)
  end

  def duration_formatter(total_seconds)
    return "-" if total_seconds.nil?

    days, remainder = total_seconds.divmod(86400)
    hours, remainder = remainder.divmod(3600)
    minutes, seconds = remainder.divmod(60)

    if days > 0
      total_minutes = (total_seconds / 60.0).ceil
      days, remainder = total_minutes.divmod(1440)
      hours, minutes = remainder.divmod(60)
      "#{pluralize(days, 'Day')}, #{pluralize(hours, 'Hour')}, #{pluralize(minutes, 'Minute')}"
    elsif hours > 0
      format("%d:%02d:%02d", hours, minutes, seconds)
    else
      format("%d:%02d", minutes, seconds)
    end
  end

  # Same day-rollover as duration_formatter, but always in words rather than
  # H:MM:SS — for pairing as a caption under a duration_hms/duration_formatter
  # value that's already showing the compact number.
  def duration_words(total_seconds, round_to_minute: false)
    return "-" if total_seconds.nil?

    total_seconds = (total_seconds / 60.0).round * 60 if round_to_minute

    days, remainder = total_seconds.divmod(86400)
    hours, remainder = remainder.divmod(3600)
    minutes, = remainder.divmod(60)

    if days > 0
      total_minutes = (total_seconds / 60.0).ceil
      days, remainder = total_minutes.divmod(1440)
      hours, minutes = remainder.divmod(60)
      "#{pluralize(days, 'Day')}, #{pluralize(hours, 'Hour')}, #{pluralize(minutes, 'Minute')}"
    elsif hours > 0
      "#{pluralize(hours, 'hour')} and #{pluralize(minutes, 'minute')}"
    else
      pluralize(minutes, "minute")
    end
  end
end
