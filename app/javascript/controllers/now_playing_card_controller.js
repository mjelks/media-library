import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "modal", "buttonGroup", "deleteBtn", "confirmBtn"]
  static values = { confirmUrl: String }

  showConfirm() {
    this.modalTarget.classList.remove("hidden")
  }

  hideConfirm() {
    this.modalTarget.classList.add("hidden")
  }

  async confirmListening() {
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    // Fade out the button group
    this.buttonGroupTarget.classList.add("opacity-0", "pointer-events-none", "transition-opacity", "duration-300")

    // After animation, hide it completely
    setTimeout(() => {
      this.buttonGroupTarget.classList.add("hidden")
    }, 300)

    // Persist the confirmation
    try {
      await fetch(this.confirmUrlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        }
      })
    } catch (error) {
      console.error("Confirm listening error:", error)
    }
  }

  async confirmDelete(event) {
    const url = event.currentTarget.dataset.nowPlayingCardUrlParam
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    // Hide modal and start fade
    this.modalTarget.classList.add("hidden")
    this.cardTarget.classList.add("opacity-0")

    try {
      const response = await fetch(url, {
        method: "DELETE",
        headers: {
          "X-CSRF-Token": csrfToken,
          "Accept": "text/vnd.turbo-stream.html"
        }
      })

      if (response.ok) {
        // Wait for fade animation to complete
        setTimeout(() => {
          // Remove the entire now-playing section
          this.element.remove()
        }, 300)
      } else {
        // Restore opacity if delete failed
        this.cardTarget.classList.remove("opacity-0")
        console.error("Delete failed")
      }
    } catch (error) {
      this.cardTarget.classList.remove("opacity-0")
      console.error("Delete error:", error)
    }
  }
}
