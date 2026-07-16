import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "modal", "buttonGroup", "deleteBtn", "confirmBtn", "pencilBtn"]
  static values = { confirmUrl: String }

  // Pencil swaps itself for the X/checkmark group; the checkmark swaps back
  exposeButtons() {
    // Clear the fade-out state confirmListening may have left behind
    this.buttonGroupTarget.classList.remove("opacity-0", "pointer-events-none", "hidden")
    if (this.hasPencilBtnTarget) this.pencilBtnTarget.classList.add("hidden")
  }

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

    // After animation, hide it completely and bring the pencil back
    setTimeout(() => {
      this.buttonGroupTarget.classList.add("hidden")
      if (this.hasPencilBtnTarget) this.pencilBtnTarget.classList.remove("hidden")
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
        // Refresh so the pane falls back to "Nothing playing right now" when
        // applicable and the cartridge (needle) stats reflect the removed
        // play — Turbo.visit replace avoids the hard-reload flash.
        if (window.Turbo) {
          window.Turbo.visit(window.location.href, { action: "replace" })
        } else {
          window.location.reload()
        }
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
