import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "listLink", "calendarLink"]

  connect() {
    this.onPopState = this.onPopState.bind(this)
    window.addEventListener("popstate", this.onPopState)
  }

  disconnect() {
    window.removeEventListener("popstate", this.onPopState)
  }

  navigate(event) {
    event.preventDefault()
    const url = event.currentTarget.getAttribute("href")
    if (url) this.load(url, { pushState: true })
  }

  onPopState() {
    this.load(window.location.href, { pushState: false })
  }

  async load(url, { pushState }) {
    try {
      const response = await fetch(url, {
        headers: { Accept: "text/html", "X-Requested-With": "XMLHttpRequest" }
      })
      if (!response.ok) return

      this.containerTarget.innerHTML = await response.text()

      // The List/Calendar tabs live outside the swapped container, so keep
      // them pointed at whatever month was just loaded.
      if (this.hasCalendarLinkTarget) this.calendarLinkTarget.setAttribute("href", url)
      if (this.hasListLinkTarget) this.listLinkTarget.setAttribute("href", url.replace("/calendar", "/month"))

      if (pushState) window.history.pushState({}, "", url)
    } catch (err) {
      console.error("calendar navigation failed:", err)
    }
  }
}
