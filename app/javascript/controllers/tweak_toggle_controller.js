import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { active: Boolean }

  toggle() {
    this.activeValue = !this.activeValue
  }

  activeValueChanged() {
    document.querySelectorAll(".tweak-hidden").forEach(el => {
      el.classList.toggle("hidden", !this.activeValue)
    })
    this.element.classList.toggle("ring-2", this.activeValue)
    this.element.classList.toggle("ring-amber-400", this.activeValue)
    this.element.classList.toggle("text-amber-600", this.activeValue)
    this.element.classList.toggle("text-gray-500", !this.activeValue)
  }
}
