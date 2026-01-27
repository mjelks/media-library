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
end
