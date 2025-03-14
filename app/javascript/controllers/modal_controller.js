import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["tab", "content"];

  connect() {
    // console.log("✅ ModalController connected!");
    
    const signIn = document.getElementById("signIn");
    // If we're on the sessions/new page, trigger the modal
    if (signIn?.textContent.length > 0) {
      this.show();
    }
  }

  show() {
    // console.log("Show method triggered!");

    // Dynamically find modal since it may be rendered later
    const modal = document.getElementById("modal");

    if (!modal) {
      console.error("❌ Modal not found!");
      return;
    }

    modal.classList.remove("hidden");
    this.switchTab("login");
  }

  hide() {
    // console.log('triggered!')
    const modal = document.getElementById("modal");

    if (modal) {
      modal.classList.add("hidden");
    }
  }

  switchTab(event) {
    const tabName = typeof event === "string" ? event : event.currentTarget.dataset.tab;

    // console.log("Switching to:", tabName);
    // console.log("Tabs available:", this.tabTargets.map(tab => tab.dataset.tab));

    this.tabTargets.forEach(tab => {
      const isActive = tab.dataset.tab === tabName;
      tab.classList.toggle("active", isActive);
      tab.classList.toggle("text-white", isActive);
      tab.classList.toggle("selected", isActive);
      tab.classList.toggle("text-gray-400", isActive);
    });

    this.contentTargets.forEach(content => {
      content.classList.toggle("hidden", content.id !== tabName);
    });
  }
}
