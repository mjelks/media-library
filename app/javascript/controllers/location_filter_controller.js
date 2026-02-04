import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mediaType", "location", "slotPositionWrapper", "slotPositionHint"]
  static values = { locations: Array, cdMediaTypeId: Number }

  connect() {
    this.filterLocations()
    this.toggleSlotPosition()
  }

  filterLocations() {
    const selectedMediaTypeId = this.mediaTypeTarget.value
    const locationSelect = this.locationTarget
    const currentLocationId = locationSelect.value

    // Clear existing options except prompt
    const prompt = locationSelect.querySelector('option[value=""]')
    locationSelect.innerHTML = ""
    if (prompt) {
      locationSelect.appendChild(prompt)
    }

    // Filter and add matching locations
    this.locationsValue.forEach(location => {
      // Show location if it has no media type OR matches the selected media type
      if (!location.media_type_id || location.media_type_id.toString() === selectedMediaTypeId) {
        const option = document.createElement("option")
        option.value = location.id
        option.textContent = location.name
        if (location.id.toString() === currentLocationId) {
          option.selected = true
        }
        locationSelect.appendChild(option)
      }
    })

    this.toggleSlotPosition()
    this.updateSlotPositionHint()
  }

  toggleSlotPosition() {
    if (!this.hasSlotPositionWrapperTarget) return

    const isCd = this.mediaTypeTarget.value === this.cdMediaTypeIdValue.toString()
    this.slotPositionWrapperTarget.style.display = isCd ? "" : "none"

    if (!isCd) {
      const input = this.slotPositionWrapperTarget.querySelector("input")
      if (input) input.value = ""
    }
  }

  updateSlotPositionHint() {
    if (!this.hasSlotPositionHintTarget) return

    const locationId = this.locationTarget.value
    if (!locationId) {
      this.slotPositionHintTarget.textContent = ""
      return
    }

    const location = this.locationsValue.find(l => l.id.toString() === locationId)
    if (location && location.max_slot_position) {
      this.slotPositionHintTarget.textContent = `Last slot position for this location is ${location.max_slot_position}`
    } else {
      this.slotPositionHintTarget.textContent = "No existing slot positions for this location"
    }
  }

  onLocationChange() {
    this.updateSlotPositionHint()
  }
}
