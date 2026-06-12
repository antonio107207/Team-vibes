import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"]

  toggle() {
    const cb = this.checkboxTarget
    cb.checked = !cb.checked
    this.element.classList.toggle("opacity-40", cb.checked)
    this.element.classList.toggle("ring-2",     cb.checked)
    this.element.classList.toggle("ring-red-500", cb.checked)
  }
}
