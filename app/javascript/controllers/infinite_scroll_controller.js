import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "sentinel", "spinner"]

  connect() {
    this.loading = false
    this.onScroll = this.checkScroll.bind(this)
    window.addEventListener("scroll", this.onScroll, { passive: true })
    // Check immediately in case the sentinel is already in view on load
    this.checkScroll()
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
  }

  checkScroll() {
    if (this.loading || !this.hasSentinelTarget) return

    const sentinel = this.sentinelTarget
    const rect = sentinel.getBoundingClientRect()
    // Trigger 300px before the sentinel reaches the bottom of the viewport
    if (rect.top <= window.innerHeight + 300) {
      this.fetchNextPage()
    }
  }

  async fetchNextPage() {
    if (this.loading) return
    this.loading = true

    const url = this.sentinelTarget.dataset.url
    if (!url) {
      this.loading = false
      return
    }

    this.spinnerTarget.classList.remove("hidden")

    try {
      const response = await fetch(url, { headers: { Accept: "text/html" } })
      if (!response.ok) return

      const html = await response.text()
      const nextUrl = response.headers.get("X-Next-Page-Url")

      const template = document.createElement("template")
      template.innerHTML = html.trim()
      this.containerTarget.append(...Array.from(template.content.childNodes))

      if (nextUrl) {
        this.sentinelTarget.dataset.url = nextUrl
      } else {
        this.sentinelTarget.remove()
      }
    } catch (err) {
      console.error("infinite scroll fetch failed:", err)
    } finally {
      this.loading = false
      this.spinnerTarget.classList.add("hidden")
      // After appending, immediately check if we need another page
      // (handles very fast scrollers or short pages)
      this.checkScroll()
    }
  }
}
