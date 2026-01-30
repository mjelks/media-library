module CdCollectionHelper
  SLOT_LETTERS_A = %w[A B C D].freeze
  SLOT_LETTERS_B = %w[E F G H].freeze

  # Convert a slot position (1-200) to a human-readable label like "1A", "2B", etc.
  # Position 1-4 = Page 1 Side A (1A, 1B, 1C, 1D)
  # Position 5-8 = Page 1 Side B (1E, 1F, 1G, 1H)
  # Position 9-12 = Page 2 Side A (2A, 2B, 2C, 2D)
  # etc.
  def slot_label_for(slot_position)
    return "—" if slot_position.nil? || slot_position <= 0

    page = ((slot_position - 1) / 8) + 1
    side = ((slot_position - 1) / 4) % 2 == 0 ? "A" : "B"
    slot_idx = (slot_position - 1) % 4
    slot_letter = side == "A" ? SLOT_LETTERS_A[slot_idx] : SLOT_LETTERS_B[slot_idx]

    "#{page}#{slot_letter}"
  end

  # Convert a (page, side, slot_index) to slot position
  # page: 1-25, side: 'A' or 'B', slot_index: 0-3
  def slot_position_for(page, side, slot_index)
    base = (page - 1) * 8
    side_offset = side == "A" ? 0 : 4
    base + side_offset + slot_index + 1
  end
end
