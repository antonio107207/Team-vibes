import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bar", "input"]
  static values  = { persistent: Boolean }

  toggle() {
    if (this.barTarget.classList.contains("hidden")) {
      this.show()
      this.inputTarget.focus()
    } else {
      this.inputTarget.value = ""
      this.hide()
    }
  }

  handleKey(event) {
    if (event.key === "Escape") {
      if (this.persistentValue) {
        // On search page: clear input and navigate to empty search
        this.inputTarget.value = ""
        this.inputTarget.closest("form").requestSubmit()
      } else {
        this.inputTarget.value = ""
        this.hide()
      }
      event.preventDefault()
    }
  }

  // When the native ✕ clears the input, go home
  clearIfEmpty() {
    if (this.inputTarget.value === "") {
      Turbo.visit("/")
    }
  }

  show() {
    this.barTarget.classList.remove("hidden")
  }

  hide() {
    this.barTarget.classList.add("hidden")
  }
}
