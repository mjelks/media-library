import { Controller } from "@hotwired/stimulus"

// Generic tab switcher — tabs and panels are matched by their data-tab attribute.
// A URL hash matching a tab name (e.g. /now_playing#up-next) opens that tab on load.
export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    const name = window.location.hash.slice(1)
    const tab = this.tabTargets.find(tab => tab.dataset.tab === name)
    if (tab && tab.offsetParent !== null) this.activate(name)
  }

  select(event) {
    const name = event.currentTarget.dataset.tab
    this.activate(name)
    history.replaceState(null, "", `#${name}`)
  }

  activate(name) {
    this.tabTargets.forEach(tab => tab.classList.toggle("selected", tab.dataset.tab === name))
    this.panelTargets.forEach(panel => panel.classList.toggle("hidden", panel.dataset.tab !== name))
  }
}
