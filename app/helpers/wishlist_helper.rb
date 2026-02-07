module WishlistHelper
  def sort_link(label, column)
    direction = if @sort_column == column && @sort_direction == "asc"
                  "desc"
    else
                  "asc"
    end

    arrow = if @sort_column == column
              @sort_direction == "asc" ? " ▲" : " ▼"
    else
              ""
    end

    link_to "#{label}#{arrow}".html_safe, wishlist_index_path(sort: column, direction: direction),
            class: "hover:text-blue-600 #{@sort_column == column ? 'text-blue-700' : ''}"
  end
end
