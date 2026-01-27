import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = {
    url: String,
    animation: { type: Number, default: 150 }
  }

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: this.animationValue,
      handle: ".drag-handle",
      ghostClass: "sortable-ghost",
      chosenClass: "sortable-chosen",
      dragClass: "sortable-drag",
      onEnd: this.onEnd.bind(this)
    })
  }

  disconnect() {
    if (this.sortable) {
      this.sortable.destroy()
    }
  }

  onEnd(event) {
    const items = this.element.querySelectorAll("[data-media-item-id]")
    const orderedIds = Array.from(items).map(item => item.dataset.mediaItemId)

    this.updatePositions(orderedIds)
  }

  async updatePositions(orderedIds) {
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        },
        body: JSON.stringify({ media_item_ids: orderedIds })
      })

      if (!response.ok) {
        console.error("Failed to update positions")
      }
    } catch (error) {
      console.error("Error updating positions:", error)
    }
  }
}
