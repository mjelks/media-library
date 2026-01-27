import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mehButton", "thumbsUpButton", "mehCount", "thumbsUpCount"]
  static values = { url: String }

  async vote(event) {
    event.preventDefault()
    const button = event.currentTarget
    const rating = button.dataset.rating
    const isActive = button.dataset.active === "true"
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    button.disabled = true

    try {
      const url = `${this.urlValue}?rating=${rating}${isActive ? "&decrement=true" : ""}`
      const response = await fetch(url, {
        method: "POST",
        headers: {
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        }
      })

      if (response.ok) {
        const data = await response.json()
        this.updateCounts(data)
        button.dataset.active = isActive ? "false" : "true"
        this.updateButtonStyle(button)
        this.flashButton(button)
      }
    } catch (error) {
      console.error("Vote error:", error)
    } finally {
      button.disabled = false
    }
  }

  updateCounts(data) {
    if (this.hasMehCountTarget) {
      this.mehCountTarget.textContent = `(${data.meh_count})`
    }
    if (this.hasThumbsUpCountTarget) {
      this.thumbsUpCountTarget.textContent = `(${data.thumbs_up_count})`
    }
  }

  updateButtonStyle(button) {
    const isActive = button.dataset.active === "true"
    const rating = button.dataset.rating

    if (rating === "meh") {
      if (isActive) {
        button.classList.remove("bg-amber-100", "hover:bg-amber-200")
        button.classList.add("bg-amber-300", "hover:bg-amber-400", "ring-2", "ring-amber-500")
      } else {
        button.classList.remove("bg-amber-300", "hover:bg-amber-400", "ring-2", "ring-amber-500")
        button.classList.add("bg-amber-100", "hover:bg-amber-200")
      }
    } else if (rating === "thumbs_up") {
      if (isActive) {
        button.classList.remove("bg-green-100", "hover:bg-green-200")
        button.classList.add("bg-green-300", "hover:bg-green-400", "ring-2", "ring-green-500")
      } else {
        button.classList.remove("bg-green-300", "hover:bg-green-400", "ring-2", "ring-green-500")
        button.classList.add("bg-green-100", "hover:bg-green-200")
      }
    }
  }

  flashButton(button) {
    button.classList.add("scale-110")
    setTimeout(() => {
      button.classList.remove("scale-110")
    }, 150)
  }
}
