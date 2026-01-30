import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = {
    url: String,
    animation: { type: Number, default: 150 },
    refreshBinder: { type: Boolean, default: false }
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

    // Restore scroll position if saved (after Turbo navigation)
    const scrollY = sessionStorage.getItem("sortableScrollPosition")
    if (scrollY) {
      sessionStorage.removeItem("sortableScrollPosition")
      requestAnimationFrame(() => {
        window.scrollTo(0, parseInt(scrollY, 10))
      })
    }
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

      if (response.ok) {
        this.updateDisplayNumbers()
        if (this.refreshBinderValue) {
          this.refreshBinderView()
        }
      } else {
        console.error("Failed to update positions")
      }
    } catch (error) {
      console.error("Error updating positions:", error)
    }
  }

  updateDisplayNumbers() {
    const items = this.element.querySelectorAll("[data-media-item-id]")
    items.forEach((item, index) => {
      // Update the position number (1., 2., 3., etc.)
      const positionEl = item.querySelector(".font-mono")
      if (positionEl) {
        positionEl.textContent = `${index + 1}.`
      }

      // Update slot label if present (for CD binders: 1A, 1B, etc.)
      const slotLabelEl = item.querySelector("[data-slot-label]")
      if (slotLabelEl) {
        const pos = index + 1
        const page = Math.floor((pos - 1) / 8) + 1
        const sideOffset = Math.floor((pos - 1) / 4) % 2
        const slotIdx = (pos - 1) % 4
        const sideALabels = ["A", "B", "C", "D"]
        const sideBLabels = ["E", "F", "G", "H"]
        const slotLetter = sideOffset === 0 ? sideALabels[slotIdx] : sideBLabels[slotIdx]
        slotLabelEl.textContent = `${page}${slotLetter}`
      }
    })
  }

  refreshBinderView() {
    // Dispatch event for other controllers to listen to
    this.dispatch("reordered")

    // Save scroll position before refresh
    sessionStorage.setItem("sortableScrollPosition", window.scrollY.toString())

    // Reload the page to update the binder view with new positions
    if (window.Turbo) {
      document.addEventListener("turbo:load", this.restoreScrollPosition, { once: true })
      window.Turbo.visit(window.location.href, { action: "replace" })
    } else {
      window.location.reload()
    }
  }

  restoreScrollPosition() {
    const scrollY = sessionStorage.getItem("sortableScrollPosition")
    if (scrollY) {
      sessionStorage.removeItem("sortableScrollPosition")
      // Use requestAnimationFrame to ensure DOM is painted
      requestAnimationFrame(() => {
        window.scrollTo(0, parseInt(scrollY, 10))
      })
    }
  }
}
