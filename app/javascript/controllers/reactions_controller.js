import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["picker"]

  connect() {
    this.outsideClick = (e) => {
      if (!this.element.contains(e.target)) this.closePicker()
    }
    document.addEventListener("click", this.outsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.outsideClick)
  }

  togglePicker(event) {
    event.stopPropagation()
    this.pickerTarget.classList.toggle("hidden")
  }

  closePicker() {
    this.pickerTarget.classList.add("hidden")
  }
}
