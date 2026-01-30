import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["page", "pageNumber", "sideLabel", "prevBtn", "nextBtn", "flipBtn", "pageNav"]
  static values = {
    currentPage: { type: Number, default: 1 },
    currentSide: { type: String, default: "A" },
    totalPages: Number
  }

  connect() {
    this.updateDisplay()
  }

  // Flip between Side A and Side B with animation
  flip() {
    const currentEl = this.getCurrentPageElement()
    if (!currentEl) return

    const newSide = this.currentSideValue === "A" ? "B" : "A"
    const direction = this.currentSideValue === "A" ? "next" : "prev"

    currentEl.classList.add(direction === "next" ? "flip-out-right" : "flip-out-left")

    setTimeout(() => {
      this.currentSideValue = newSide
      this.updateDisplay()

      const newEl = this.getCurrentPageElement()
      if (newEl) {
        newEl.classList.remove("flip-out-right", "flip-out-left")
        newEl.classList.add(direction === "next" ? "flip-in-left" : "flip-in-right")
        setTimeout(() => {
          newEl.classList.remove("flip-in-left", "flip-in-right")
        }, 300)
      }
    }, 300)
  }

  // Go to next page (no animation)
  next() {
    if (this.currentPageValue < this.totalPagesValue) {
      this.currentPageValue++
      this.currentSideValue = "A"
      this.updateDisplay()
    }
  }

  // Go to previous page (no animation)
  prev() {
    if (this.currentPageValue > 1) {
      this.currentPageValue--
      this.currentSideValue = "A"
      this.updateDisplay()
    }
  }

  // Jump to specific page from dropdown (no animation)
  goToPage(event) {
    const page = parseInt(event.currentTarget.value, 10)
    if (page !== this.currentPageValue && page >= 1 && page <= this.totalPagesValue) {
      this.currentPageValue = page
      this.currentSideValue = "A"
      this.updateDisplay()
    }
  }

  // Jump to specific page from quick nav (no animation)
  jumpToPage(event) {
    const page = parseInt(event.currentTarget.dataset.page, 10)
    if (page >= 1 && page <= this.totalPagesValue) {
      this.currentPageValue = page
      this.currentSideValue = "A"
      this.updateDisplay()
    }
  }

  getCurrentPageElement() {
    const index = (this.currentPageValue - 1) * 2 + (this.currentSideValue === "A" ? 0 : 1)
    return this.pageTargets[index]
  }

  updateDisplay() {
    // Show/hide pages - each page has 2 elements (Side A and Side B)
    this.pageTargets.forEach((page, index) => {
      const pageNum = Math.floor(index / 2) + 1
      const side = index % 2 === 0 ? "A" : "B"
      const isVisible = pageNum === this.currentPageValue && side === this.currentSideValue
      page.classList.toggle("hidden", !isVisible)
    })

    // Update page number display
    if (this.hasPageNumberTarget) {
      this.pageNumberTarget.textContent = `Page ${this.currentPageValue} of ${this.totalPagesValue}`
    }

    // Update side label
    if (this.hasSideLabelTarget) {
      this.sideLabelTarget.textContent = `Side ${this.currentSideValue}`
    }

    // Update flip button text
    if (this.hasFlipBtnTarget) {
      this.flipBtnTarget.textContent = this.currentSideValue === "A" ? "Flip to Side B" : "Flip to Side A"
    }

    // Update button states
    if (this.hasPrevBtnTarget) {
      this.prevBtnTarget.disabled = this.currentPageValue === 1
      this.prevBtnTarget.classList.toggle("opacity-50", this.currentPageValue === 1)
      this.prevBtnTarget.classList.toggle("cursor-not-allowed", this.currentPageValue === 1)
    }

    if (this.hasNextBtnTarget) {
      this.nextBtnTarget.disabled = this.currentPageValue === this.totalPagesValue
      this.nextBtnTarget.classList.toggle("opacity-50", this.currentPageValue === this.totalPagesValue)
      this.nextBtnTarget.classList.toggle("cursor-not-allowed", this.currentPageValue === this.totalPagesValue)
    }

    // Update select dropdown
    const select = this.element.querySelector("select")
    if (select) {
      select.value = this.currentPageValue
    }

    // Update quick nav indicators
    const navButtons = this.element.querySelectorAll("[data-page]")
    navButtons.forEach((btn) => {
      const page = parseInt(btn.dataset.page, 10)
      const isActive = page === this.currentPageValue
      btn.classList.toggle("bg-blue-600", isActive)
      btn.classList.toggle("bg-gray-300", !isActive)
    })
  }

  keydown(event) {
    if (event.key === "ArrowRight") {
      event.preventDefault()
      this.next()
    } else if (event.key === "ArrowLeft") {
      event.preventDefault()
      this.prev()
    } else if (event.key === " " || event.key === "f") {
      event.preventDefault()
      this.flip()
    }
  }
}
