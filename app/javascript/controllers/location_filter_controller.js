import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mediaType", "location"]
  static values = { locations: Array }

  connect() {
    this.filterLocations()
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
  }
}
