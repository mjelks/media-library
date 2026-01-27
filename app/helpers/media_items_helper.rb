module MediaItemsHelper
  def display_year(media_item)
    original_year = media_item.release&.original_year
    reissue_year = media_item.year

    return "-" if original_year.nil? && reissue_year.nil?

    if original_year.nil?
      reissue_year.to_s
    elsif reissue_year.nil? || reissue_year == original_year
      original_year.to_s
    else
      "#{original_year} (#{reissue_year} reissue)"
    end
  end

  def total_lp_count(media_items)
    media_items.sum(:item_count)
  end

  def spine_width_multiplier(media_item)
    case media_item.item_count
    when 1 then 1.0
    when 2 then 1.5
    else 2.0
    end
  end

  def item_count_display(media_item)
    return "" if media_item.item_count <= 1
    " (#{media_item.item_count})"
  end
end
