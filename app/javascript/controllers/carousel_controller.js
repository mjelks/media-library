import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  previous() {
    const firstVisible = this.firstVisibleIndex()
    const scrollAmount = this.itemTargets[Math.max(0, firstVisible - 1)].offsetWidth
    this.element.scrollBy({ left: -scrollAmount, behavior: 'smooth' })
  }

  next() {
    const lastVisible = this.lastVisibleIndex()
    const scrollAmount = this.itemTargets[Math.min(this.itemTargets.length - 1, lastVisible + 1)].offsetWidth
    this.element.scrollBy({ left: scrollAmount, behavior: 'smooth' })
  }

  firstVisibleIndex() {
    return this.itemTargets.findIndex(item => 
      item.offsetLeft + item.offsetWidth >= this.element.scrollLeft
    )
  }

  lastVisibleIndex() {
    return this.itemTargets.findIndex(item => 
      item.offsetLeft + item.offsetWidth >= this.element.scrollLeft + this.element.offsetWidth
    )
  }
}