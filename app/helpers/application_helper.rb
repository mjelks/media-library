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
    darken_color(color, 0.3)
  end

  private

  def darken_color(hex_color, amount)
    hex = hex_color.gsub("#", "")
    r = [ (hex[0..1].to_i(16) * (1 - amount)).to_i, 0 ].max
    g = [ (hex[2..3].to_i(16) * (1 - amount)).to_i, 0 ].max
    b = [ (hex[4..5].to_i(16) * (1 - amount)).to_i, 0 ].max
    "#%02x%02x%02x" % [ r, g, b ]
  end
end
