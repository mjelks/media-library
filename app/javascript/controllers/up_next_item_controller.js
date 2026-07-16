import { Controller } from "@hotwired/stimulus"

// Row-level actions for an Up Next playlist item — remove without a page reload
export default class extends Controller {
  static values = { removeUrl: String }

  async remove(event) {
    event.preventDefault()
    const button = event.currentTarget
    button.disabled = true

    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content
    try {
      const response = await fetch(this.removeUrlValue, {
        method: "DELETE",
        headers: {
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        }
      })
      if (!response.ok) {
        console.error("Failed to remove from Up Next")
        button.disabled = false
        return
      }
    } catch (error) {
      console.error("Queue error:", error)
      button.disabled = false
      return
    }

    this.element.remove()

    // Queue is empty again — return to Now Playing, drop the tab bar, restore the plain heading
    const list = document.getElementById("up-next-list")
    if (list && list.children.length === 0) {
      document.querySelector("#now-playing-tab-bar [data-tab='now-playing']")?.click()
      document.getElementById("up-next-section")?.classList.add("hidden")
      document.getElementById("now-playing-tab-bar")?.classList.add("hidden")
      document.getElementById("now-playing-heading")?.classList.remove("hidden")
    }
  }
}
