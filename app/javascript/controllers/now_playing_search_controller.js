import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "queueToggle", "queueBadge"]
  static values = { url: String, randomUrl: String, vinylDescription: String, cdDescription: String }

  connect() {
    this.selectedIndex = -1
    this.results = []
    this.debounceTimeout = null
    this.mediaType = "Vinyl" // Default
    this.randomTooltip = null

    // Close results when clicking outside
    document.addEventListener("click", this.handleClickOutside.bind(this))

    // Listen for media type changes from the toggle controller
    this.element.addEventListener("media-type-toggle:changed", this.handleMediaTypeChange.bind(this))
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside.bind(this))
    this.element.removeEventListener("media-type-toggle:changed", this.handleMediaTypeChange.bind(this))
    if (this.debounceTimeout) clearTimeout(this.debounceTimeout)
    this.hideRandomTooltip()
  }

  handleMediaTypeChange(event) {
    this.mediaType = event.detail.mediaType
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideResults()
    }
  }

  search() {
    const query = this.inputTarget.value.trim()

    // Clear previous timeout
    if (this.debounceTimeout) {
      clearTimeout(this.debounceTimeout)
    }

    if (query.length < 2) {
      this.hideResults()
      return
    }

    // Debounce the search
    this.debounceTimeout = setTimeout(() => {
      this.performSearch(query)
    }, 200)
  }

  async performSearch(query) {
    try {
      const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}&media_type=${encodeURIComponent(this.mediaType)}`, {
        headers: {
          "Accept": "application/json"
        }
      })

      if (!response.ok) {
        console.error("Search failed")
        return
      }

      this.results = await response.json()
      this.selectedIndex = -1
      this.renderResults()
    } catch (error) {
      console.error("Search error:", error)
    }
  }

  async fetchRandom() {
    try {
      const response = await fetch(`${this.randomUrlValue}?media_type=${encodeURIComponent(this.mediaType)}`, {
        headers: {
          "Accept": "application/json"
        }
      })

      if (!response.ok) {
        console.error("Random fetch failed")
        return
      }

      const data = await response.json()
      this.results = data.results
      this.selectedIndex = -1

      if (this.results.length === 0) {
        this.resultsTarget.innerHTML = `
          <div class="px-4 py-3 text-gray-500 text-center">
            No matches found for: ${data.filter_description}
          </div>
        `
        this.showResults()
      } else {
        this.renderResults()
      }
    } catch (error) {
      console.error("Random error:", error)
    }
  }

  renderResults() {
    if (this.results.length === 0) {
      this.resultsTarget.innerHTML = `
        <div class="px-4 py-3 text-gray-500 text-center">
          No results found
        </div>
      `
      this.showResults()
      return
    }

    const html = this.results.map((item, index) => `
      <div class="flex items-center gap-3 px-4 py-3 cursor-pointer hover:bg-gray-50 transition-colors ${item.playing || item.queued ? 'opacity-50' : ''} ${index === this.selectedIndex ? 'bg-blue-50' : ''}"
           data-index="${index}"
           data-action="click->now-playing-search#selectResult mouseenter->now-playing-search#highlightResult">
        ${item.cover_url
          ? `<img src="${item.cover_url}" class="w-12 h-12 object-cover rounded shadow" alt="">`
          : `<div class="w-12 h-12 bg-gray-200 rounded flex items-center justify-center">
              <svg class="w-6 h-6 text-gray-400" fill="currentColor" viewBox="0 0 20 20">
                <path d="M18 3a1 1 0 00-1.196-.98l-10 2A1 1 0 006 5v9.114A4.369 4.369 0 005 14c-1.657 0-3 .895-3 2s1.343 2 3 2 3-.895 3-2V7.82l8-1.6v5.894A4.37 4.37 0 0015 12c-1.657 0-3 .895-3 2s1.343 2 3 2 3-.895 3-2V3z"/>
              </svg>
            </div>`
        }
        <div class="flex-1 min-w-0">
          <div class="font-medium truncate">${this.escapeHtml(item.title || 'Unknown Album')}</div>
          <div class="text-sm text-gray-600 truncate">${this.escapeHtml(item.artist || 'Unknown Artist')}</div>
        </div>
        <div class="flex items-center gap-2 flex-shrink-0">
          <span class="text-sm text-gray-400">${item.play_count || 0} plays</span>
          ${item.playing
            ? `<span class="px-2 py-0.5 text-xs font-medium bg-blue-100 text-blue-700 rounded-full whitespace-nowrap"
                     title="This album is playing right now — click to view">Currently Playing</span>`
            : item.queued
            ? `<span class="px-2 py-0.5 text-xs font-medium bg-green-100 text-green-700 rounded-full whitespace-nowrap"
                     title="Already in Up Next — click to view">In Up Next</span>`
            : `<button type="button"
                  class="p-1.5 rounded-md bg-indigo-100 hover:bg-indigo-200 text-indigo-700 transition-colors"
                  title="Add to Up Next"
                  data-item-id="${item.id}"
                  data-action="click->now-playing-search#addToQueue">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
            </svg>
          </button>`
          }
        </div>
      </div>
    `).join('')

    this.resultsTarget.innerHTML = html
    this.showResults()
  }

  handleKeydown(event) {
    if (!this.resultsTarget.classList.contains("hidden")) {
      switch (event.key) {
        case "ArrowDown":
          event.preventDefault()
          this.selectedIndex = Math.min(this.selectedIndex + 1, this.results.length - 1)
          this.renderResults()
          break
        case "ArrowUp":
          event.preventDefault()
          this.selectedIndex = Math.max(this.selectedIndex - 1, -1)
          this.renderResults()
          break
        case "Enter":
          event.preventDefault()
          if (this.selectedIndex >= 0 && this.results[this.selectedIndex]) {
            const item = this.results[this.selectedIndex]
            if (item.playing) {
              this.showPlayingItem()
            } else if (item.queued) {
              this.showQueuedItem(item)
            } else if (this.hasQueueToggleTarget && this.queueToggleTarget.checked) {
              this.addToQueueById(item.id)
            } else {
              this.playItem(item)
            }
          }
          break
        case "Escape":
          this.hideResults()
          break
      }
    }
  }

  highlightResult(event) {
    const newIndex = parseInt(event.currentTarget.dataset.index, 10)
    if (newIndex === this.selectedIndex) return

    // Remove highlight from previous
    const items = this.resultsTarget.querySelectorAll("[data-index]")
    items.forEach((item, i) => {
      item.classList.toggle("bg-blue-50", i === newIndex)
    })
    this.selectedIndex = newIndex
  }

  selectResult(event) {
    event.preventDefault()
    event.stopPropagation()
    const index = parseInt(event.currentTarget.dataset.index, 10)
    const item = this.results[index]
    if (item) {
      if (item.playing) {
        this.showPlayingItem()
      } else if (item.queued) {
        this.showQueuedItem(item)
      } else if (this.hasQueueToggleTarget && this.queueToggleTarget.checked) {
        this.addToQueueById(item.id)
      } else {
        this.playItem(item)
      }
    }
  }

  // The picked result is already playing — jump to the Now Playing card
  showPlayingItem() {
    this.hideResults()
    this.inputTarget.value = ""
    document.querySelector("#now-playing-tab-bar [data-tab='now-playing']")?.click()
    const card = document.querySelector('[data-tabs-target="panel"][data-tab="now-playing"] [data-now-playing-card-target="card"]')
    if (card) {
      card.scrollIntoView({ block: "nearest", behavior: "smooth" })
      card.classList.add("ring-2", "ring-indigo-300")
      setTimeout(() => card.classList.remove("ring-2", "ring-indigo-300"), 2000)
    }
  }

  // A queued result was picked — jump to its row in the Up Next tab instead of playing
  showQueuedItem(item) {
    this.hideResults()
    this.inputTarget.value = ""
    document.querySelector("#now-playing-tab-bar [data-tab='up-next']")?.click()
    const row = document.querySelector(`#up-next-list [data-media-item-id="${item.id}"]`)
    if (row) this.flashRow(row)
  }

  flashRow(row) {
    row.scrollIntoView({ block: "nearest", behavior: "smooth" })
    row.classList.remove("bg-white")
    row.classList.add("bg-indigo-50", "ring-2", "ring-indigo-300")
    setTimeout(() => {
      row.classList.add("bg-white")
      row.classList.remove("bg-indigo-50", "ring-2", "ring-indigo-300")
    }, 2000)
  }

  toggleQueueMode() {
    const isQueueMode = this.queueToggleTarget.checked
    if (this.hasQueueBadgeTarget) {
      this.queueBadgeTarget.classList.toggle("hidden", !isQueueMode)
    }
    this.inputTarget.placeholder = isQueueMode
      ? "Search to add to Up Next..."
      : "Search by artist or album title..."
  }

  async playItem(item) {
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    try {
      const response = await fetch(`/now_playing/${item.id}/play`, {
        method: "POST",
        headers: {
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        }
      })

      if (response.ok) {
        // Refresh the page to show updated recently played / cartridge stats.
        // Turbo.visit replace avoids the hard-reload flash that window.location.reload() causes.
        if (window.Turbo) {
          window.Turbo.visit(window.location.href, { action: "replace" })
        } else {
          window.location.reload()
        }
      } else {
        console.error("Failed to mark as playing")
      }
    } catch (error) {
      console.error("Play error:", error)
    }
  }

  async addToQueue(event) {
    event.preventDefault()
    event.stopPropagation()

    this.hideResults()
    this.inputTarget.value = ""

    const button = event.currentTarget
    button.disabled = true

    await this.addToQueueById(button.dataset.itemId)

    // Visual confirmation after the fetch completes
    button.innerHTML = `<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
    </svg>`
    button.classList.remove("bg-indigo-100", "hover:bg-indigo-200", "text-indigo-700")
    button.classList.add("bg-green-100", "text-green-700")
  }

  async addToQueueById(itemId) {
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content
    try {
      const response = await fetch("/playlist", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        },
        body: JSON.stringify({ media_item_id: itemId })
      })
      if (response.ok) {
        const data = await response.json()
        if (data.html) {
          const section = document.getElementById("up-next-section")
          const list = document.getElementById("up-next-list")
          if (section) section.classList.remove("hidden")
          if (list) list.insertAdjacentHTML("beforeend", data.html)
          // Swap the plain heading for the Now Playing / Up Next tab bar
          document.getElementById("now-playing-tab-bar")?.classList.remove("hidden")
          document.getElementById("now-playing-heading")?.classList.add("hidden")
          // Open the Up Next tab and flash the new row
          document.querySelector("#now-playing-tab-bar [data-tab='up-next']")?.click()
          const row = list?.lastElementChild
          if (row) this.flashRow(row)
        }
        this.hideResults()
        this.inputTarget.value = ""
      } else {
        console.error("Failed to add to queue")
      }
    } catch (error) {
      console.error("Queue error:", error)
    }
  }

  showResults() {
    this.resultsTarget.classList.remove("hidden")
  }

  hideResults() {
    this.resultsTarget.classList.add("hidden")
    this.selectedIndex = -1
  }

  showRandomTooltip(event) {
    if (this.randomTooltip) return

    const description = this.mediaType === "CD" ? this.cdDescriptionValue : this.vinylDescriptionValue
    if (!description) return

    this.randomTooltip = document.createElement("div")
    this.randomTooltip.innerHTML = `<span class="font-semibold">${this.escapeHtml(this.mediaType)} random picks:</span><br>${this.escapeHtml(description)}`
    this.randomTooltip.className = "fixed z-50 px-3 py-2 text-xs text-white bg-gray-900 rounded shadow-lg pointer-events-none max-w-xs"
    document.body.appendChild(this.randomTooltip)

    const btn = event.currentTarget
    const rect = btn.getBoundingClientRect()
    const tip = this.randomTooltip.getBoundingClientRect()
    let left = rect.right - tip.width
    let top = rect.top - tip.height - 6
    if (left < 4) left = 4
    if (top < 4) top = rect.bottom + 6
    this.randomTooltip.style.left = `${left}px`
    this.randomTooltip.style.top = `${top}px`
  }

  hideRandomTooltip() {
    if (this.randomTooltip) {
      this.randomTooltip.remove()
      this.randomTooltip = null
    }
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
