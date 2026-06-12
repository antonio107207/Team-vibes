import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }

  hide(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }

  connect() {
    this.clickOutside = this.hide.bind(this)
    document.addEventListener("click", this.clickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.clickOutside)
  }
}
