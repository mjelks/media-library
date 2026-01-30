import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]
  static values = { url: String, randomUrl: String }

  connect() {
    this.selectedIndex = -1
    this.results = []
    this.debounceTimeout = null
    this.mediaType = "Vinyl" // Default

    // Close results when clicking outside
    document.addEventListener("click", this.handleClickOutside.bind(this))

    // Listen for media type changes from the toggle controller
    this.element.addEventListener("media-type-toggle:changed", this.handleMediaTypeChange.bind(this))
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside.bind(this))
    this.element.removeEventListener("media-type-toggle:changed", this.handleMediaTypeChange.bind(this))
    if (this.debounceTimeout) {
      clearTimeout(this.debounceTimeout)
    }
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

      this.results = await response.json()
      this.selectedIndex = -1

      if (this.results.length === 0) {
        this.resultsTarget.innerHTML = `
          <div class="px-4 py-3 text-gray-500 text-center">
            No albums available (all played within the last 60 days)
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
      <div class="flex items-center gap-3 px-4 py-3 cursor-pointer hover:bg-gray-50 transition-colors ${index === this.selectedIndex ? 'bg-blue-50' : ''}"
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
        <div class="text-sm text-gray-400">
          ${item.play_count || 0} plays
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
            this.playItem(this.results[this.selectedIndex])
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
    if (this.results[index]) {
      this.playItem(this.results[index])
    }
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
        // Reload the page to show updated recently played
        window.location.reload()
      } else {
        console.error("Failed to mark as playing")
      }
    } catch (error) {
      console.error("Play error:", error)
    }
  }

  showResults() {
    this.resultsTarget.classList.remove("hidden")
  }

  hideResults() {
    this.resultsTarget.classList.add("hidden")
    this.selectedIndex = -1
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
