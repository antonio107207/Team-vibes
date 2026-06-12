import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track", "prev", "next"]

  connect() {
    this.update()
    this.trackTarget.addEventListener("scroll", this.update, { passive: true })
    this.ro = new ResizeObserver(this.update)
    this.ro.observe(this.trackTarget)
  }

  disconnect() {
    this.trackTarget.removeEventListener("scroll", this.update)
    this.ro?.disconnect()
  }

  scrollPrev() {
    this.trackTarget.scrollBy({ left: -180, behavior: "smooth" })
  }

  scrollNext() {
    this.trackTarget.scrollBy({ left: 180, behavior: "smooth" })
  }

  update = () => {
    const { scrollLeft, scrollWidth, clientWidth } = this.trackTarget
    this.setVisible(this.prevTarget, scrollLeft > 1)
    this.setVisible(this.nextTarget, scrollLeft + clientWidth < scrollWidth - 1)
  }

  setVisible(el, visible) {
    el.classList.toggle("opacity-0", !visible)
    el.classList.toggle("pointer-events-none", !visible)
  }
}
