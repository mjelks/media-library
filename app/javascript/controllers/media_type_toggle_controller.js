import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]
  static values = { current: String }

  connect() {
    this.updateButtonStates()
  }

  select(event) {
    const mediaType = event.currentTarget.dataset.mediaType
    if (mediaType === this.currentValue) return

    this.currentValue = mediaType
    this.updateButtonStates()

    // Dispatch custom event for other controllers to listen to
    this.dispatch("changed", { detail: { mediaType } })
  }

  updateButtonStates() {
    this.buttonTargets.forEach(button => {
      const isActive = button.dataset.mediaType === this.currentValue
      button.classList.toggle("themed-toggle-active", isActive)
      button.classList.toggle("themed-btn-secondary", !isActive)
    })
  }
}
