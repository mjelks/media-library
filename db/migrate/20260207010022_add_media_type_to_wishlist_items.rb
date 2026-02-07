class AddMediaTypeToWishlistItems < ActiveRecord::Migration[8.1]
  def change
    add_reference :wishlist_items, :media_type, null: true, foreign_key: true
  end
end
