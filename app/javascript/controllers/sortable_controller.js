import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = {
    url: String,
    animation: { type: Number, default: 150 },
    refreshBinder: { type: Boolean, default: false },
    idAttribute: { type: String, default: "data-media-item-id" },
    paramName: { type: String, default: "media_item_ids" },
    simpleMode: { type: Boolean, default: false }
  }

  connect() {
    const draggable = this.simpleModeValue
      ? `[${this.idAttributeValue}]`
      : "[data-media-item-id], [data-empty-slot]"

    this.sortable = Sortable.create(this.element, {
      animation: this.animationValue,
      handle: ".drag-handle",
      ghostClass: "sortable-ghost",
      chosenClass: "sortable-chosen",
      dragClass: "sortable-drag",
      draggable: draggable,
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
    if (this.simpleModeValue) {
      const items = this.element.querySelectorAll(`[${this.idAttributeValue}]`)
      const orderedIds = Array.from(items).map(el => el.getAttribute(this.idAttributeValue))
      this.updatePositions(orderedIds)
      return
    }

    // Get all elements (items and empty slots) in DOM order after drag
    const allElements = this.element.querySelectorAll("[data-media-item-id], [data-empty-slot]")

    // Build slot assignments: each position gets a slot number
    // Items take the slot of their position, empty slots mark gaps
    let currentSlot = 1
    const itemSlots = []

    Array.from(allElements).forEach(el => {
      if (el.dataset.emptySlot) {
        // Empty slot - use its original slot position and skip past it
        currentSlot = parseInt(el.dataset.emptySlot) + 1
      } else if (el.dataset.mediaItemId) {
        // Item - assign current slot and increment
        itemSlots.push({ id: el.dataset.mediaItemId, slot: currentSlot })
        currentSlot++
      }
    })

    // Send slot assignments to server
    this.updatePositionsWithSlots(itemSlots)
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
        body: JSON.stringify({ [this.paramNameValue]: orderedIds })
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

  async updatePositionsWithSlots(itemSlots) {
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        },
        body: JSON.stringify({ item_slots: itemSlots })
      })

      if (response.ok) {
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
