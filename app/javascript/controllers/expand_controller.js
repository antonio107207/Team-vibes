import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    requestAnimationFrame(() => {
      if (this.element.scrollHeight <= this.element.clientHeight + 2) {
        this.element.classList.remove("cursor-pointer")
      }
    })
  }

  expand() {
    this.element.classList.remove("line-clamp-3")
    // Explicitly reset webkit-box display so the block height recalculates
    this.element.style.display = "block"
    this.element.style.overflow = "visible"
    this.element.style.webkitLineClamp = "unset"
    this.element.classList.remove("cursor-pointer")
    this.element.removeAttribute("data-action")
  }
}
