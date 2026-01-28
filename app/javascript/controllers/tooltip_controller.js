import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { text: String }

  connect() {
    this.tooltip = null
  }

  show(event) {
    if (this.tooltip) return

    this.tooltip = document.createElement("div")
    this.tooltip.textContent = this.textValue
    this.tooltip.className = "fixed z-50 px-2 py-1 text-xs font-medium text-white bg-gray-900 rounded shadow-lg pointer-events-none whitespace-nowrap"

    document.body.appendChild(this.tooltip)
    this.position(event)
  }

  position(event) {
    if (!this.tooltip) return

    const rect = this.element.getBoundingClientRect()
    const tooltipRect = this.tooltip.getBoundingClientRect()

    // Position above the element, right-aligned
    let left = rect.right - tooltipRect.width
    let top = rect.top - tooltipRect.height - 6

    // Keep within viewport
    if (left < 4) left = 4
    if (top < 4) {
      // Show below if no room above
      top = rect.bottom + 6
    }

    this.tooltip.style.left = `${left}px`
    this.tooltip.style.top = `${top}px`
  }

  hide() {
    if (this.tooltip) {
      this.tooltip.remove()
      this.tooltip = null
    }
  }

  disconnect() {
    this.hide()
  }
}
