import { Controller } from "@hotwired/stimulus";

const MOBILE_BREAKPOINT = 768;

export default class extends Controller {
  static targets = ["menu"];

  connect() {
    this._onResize = this._hideMenuOnDesktop.bind(this);
    window.addEventListener("resize", this._onResize);
  }

  disconnect() {
    window.removeEventListener("resize", this._onResize);
  }

  toggleMenu() {
    const isHidden = this.menuTarget.classList.contains("hidden");
    if (isHidden) {
      this.menuTarget.classList.remove("hidden");
      this.menuTarget.style.display = "flex";
    } else {
      this.menuTarget.classList.add("hidden");
      this.menuTarget.style.display = "";
    }
  }

  _hideMenuOnDesktop() {
    if (window.innerWidth >= MOBILE_BREAKPOINT) {
      this.menuTarget.classList.add("hidden");
      this.menuTarget.style.display = "";
    }
  }
}
