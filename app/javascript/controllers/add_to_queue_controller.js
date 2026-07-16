import { Controller } from "@hotwired/stimulus"

const PLUS_STATE = `<span class="flex flex-col items-center">
  <svg class="w-12 h-12 text-white drop-shadow-lg" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.5">
    <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4"/>
  </svg>
  <span class="mt-1 h-4 flex items-center text-white text-xs font-semibold drop-shadow whitespace-nowrap">Add to Up Next</span>
</span>`

const QUEUED_STATE = `<span class="group/queued flex flex-col items-center">
  <span class="relative w-12 h-12">
    <svg class="absolute inset-0 w-12 h-12 text-green-400 drop-shadow-lg transition-opacity duration-200 group-hover/queued:opacity-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.5">
      <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/>
    </svg>
    <svg class="absolute inset-0 w-12 h-12 text-red-400 drop-shadow-lg opacity-0 transition-opacity duration-200 group-hover/queued:opacity-100" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.5">
      <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
    </svg>
  </span>
  <span class="relative mt-1 h-4 flex items-center justify-center">
    <span class="text-white text-xs font-semibold drop-shadow whitespace-nowrap transition-opacity duration-200 group-hover/queued:opacity-0">In Up Next</span>
    <span class="absolute text-white text-xs font-semibold drop-shadow whitespace-nowrap opacity-0 transition-opacity duration-200 group-hover/queued:opacity-100">Remove from Up Next</span>
  </span>
</span>`

const REMOVED_FEEDBACK = `<span class="flex flex-col items-center gap-1">
  <svg class="w-12 h-12 text-red-400 drop-shadow-lg" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.5">
    <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
  </svg>
  <span class="text-white text-xs font-semibold drop-shadow">Removed from Up Next</span>
</span>`

export default class extends Controller {
  static values = { mediaItemId: Number, queued: Boolean }

  async toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    if (this.element.disabled) return
    this.element.disabled = true

    if (this.queuedValue) {
      await this.remove()
    } else {
      await this.add()
    }
  }

  async add() {
    const response = await this.request("/playlist", "POST", { media_item_id: this.mediaItemIdValue })
    if (!response) {
      this.element.disabled = false
      return
    }

    const data = await response.json()
    if (data.html) {
      const section = document.getElementById("up-next-section")
      const list = document.getElementById("up-next-list")
      if (section) section.classList.remove("hidden")
      if (list) list.insertAdjacentHTML("beforeend", data.html)
    }

    this.setQueued(true)
    this.element.disabled = false
  }

  async remove() {
    const response = await this.request(`/playlist/by_media_item/${this.mediaItemIdValue}`, "DELETE")
    if (!response) {
      this.element.disabled = false
      return
    }
    await response.json()

    // If the Up Next list is on this page, drop the matching row
    const row = document.querySelector(`#up-next-list [data-media-item-id="${this.mediaItemIdValue}"]`)
    if (row) {
      row.remove()
      const list = document.getElementById("up-next-list")
      const section = document.getElementById("up-next-section")
      if (section && list && list.children.length === 0) section.classList.add("hidden")
    }

    this.setQueued(false)

    // Brief confirmation before settling back to the "+" state (stays disabled meanwhile)
    this.element.innerHTML = REMOVED_FEEDBACK
    setTimeout(() => {
      this.element.innerHTML = PLUS_STATE
      this.element.disabled = false
    }, 1200)
  }

  setQueued(queued) {
    this.queuedValue = queued
    this.element.innerHTML = queued ? QUEUED_STATE : PLUS_STATE
  }

  async request(url, method, body = null) {
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content
    try {
      const response = await fetch(url, {
        method: method,
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        },
        body: body ? JSON.stringify(body) : null
      })
      if (!response.ok) {
        console.error(`${method} ${url} failed`)
        return null
      }
      return response
    } catch (error) {
      console.error("Queue error:", error)
      return null
    }
  }
}
