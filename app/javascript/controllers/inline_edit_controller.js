import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "form", "input"]
  static values = { url: String }

  connect() {
    this.isEditing = false
  }

  edit(event) {
    event.preventDefault()
    this.isEditing = true
    this.displayTarget.classList.add("hidden")
    this.formTarget.classList.remove("hidden")
    this.inputTarget.focus()
    // Place cursor at end
    this.inputTarget.setSelectionRange(this.inputTarget.value.length, this.inputTarget.value.length)
  }

  cancel(event) {
    if (event) event.preventDefault()
    this.isEditing = false
    this.formTarget.classList.add("hidden")
    this.displayTarget.classList.remove("hidden")
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.cancel()
    } else if (event.key === "Enter" && !event.altKey) {
      // Enter saves, Alt+Enter allows line breaks
      event.preventDefault()
      this.save(event)
    }
  }

  async save(event) {
    event.preventDefault()
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content
    const notes = this.inputTarget.value

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        },
        body: JSON.stringify({ notes: notes })
      })

      if (response.ok) {
        const data = await response.json()
        this.updateDisplay(data.notes)
        this.cancel()
      } else {
        console.error("Failed to save notes")
      }
    } catch (error) {
      console.error("Save error:", error)
    }
  }

  updateDisplay(notes) {
    const displayText = this.displayTarget.querySelector("[data-notes-text]")
    const placeholder = this.displayTarget.querySelector("[data-notes-placeholder]")

    if (notes && notes.trim()) {
      if (displayText) displayText.textContent = notes
      if (placeholder) placeholder.classList.add("hidden")
      if (displayText) displayText.classList.remove("hidden")
    } else {
      if (displayText) displayText.classList.add("hidden")
      if (placeholder) placeholder.classList.remove("hidden")
    }
  }
}
