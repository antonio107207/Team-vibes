import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "from", "to"]
  static values  = { locale: String }

  connect() {
    document.addEventListener("turbo:before-cache", this.clearDisplay)
    if (!window.flatpickr) return

    this.displayTarget.value = ""

    const from = this.parseISO(this.fromTarget.value)
    const to   = this.parseISO(this.toTarget.value)

    this.fp = window.flatpickr(this.displayTarget, {
      mode: "range",
      dateFormat: "d.m.Y",
      locale: this.localeValue === "uk" ? "uk" : undefined,
      defaultDate: from && to ? [from, to] : undefined,
      disableMobile: true,
      onChange: (dates) => {
        if (dates.length === 2) {
          this.fromTarget.value = this.toISO(dates[0])
          this.toTarget.value   = this.toISO(dates[1])
          this.element.closest("form").requestSubmit()
        }
      }
    })
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.clearDisplay)
    this.fp?.destroy()
  }

  clear() {
    this.fp?.clear()
    this.fromTarget.value = ""
    this.toTarget.value   = ""
    this.element.closest("form").requestSubmit()
  }

  clearDisplay = () => {
    this.displayTarget.value = ""
    this.fromTarget.value = ""
    this.toTarget.value   = ""
  }

  // Creates a LOCAL-time Date to avoid ISO UTC-midnight timezone shifts
  parseISO(str) {
    if (!str) return null
    const parts = str.split("-").map(Number)
    if (parts.length !== 3 || parts.some(isNaN)) return null
    return new Date(parts[0], parts[1] - 1, parts[2])
  }

  toISO(date) {
    const y = date.getFullYear()
    const m = String(date.getMonth() + 1).padStart(2, "0")
    const d = String(date.getDate()).padStart(2, "0")
    return `${y}-${m}-${d}`
  }
}
