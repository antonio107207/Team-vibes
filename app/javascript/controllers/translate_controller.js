import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "description", "button"]

  connect() {
    this.originalTitle       = this.hasTitleTarget       ? this.titleTarget.innerHTML       : null
    this.originalDescription = this.hasDescriptionTarget ? this.descriptionTarget.innerHTML : null
    this.cachedTitle         = null
    this.cachedDescription   = null
    this.isTranslated        = false
  }

  async toggle() {
    if (this.isTranslated) {
      this.showOriginal()
    } else {
      await this.fetchTranslation()
    }
  }

  async fetchTranslation() {
    this.buttonTarget.disabled = true
    this.buttonTarget.textContent = "..."

    if (this.cachedTitle !== null || this.cachedDescription !== null) {
      this.applyTranslation()
      return
    }

    try {
      const body = new FormData()
      if (this.hasTitleTarget)       body.append("title",       this.titleTarget.textContent.trim())
      if (this.hasDescriptionTarget) body.append("description", this.descriptionTarget.innerHTML)

      const res = await fetch("/translations", {
        method: "POST",
        headers: { "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content },
        body
      })
      if (!res.ok) throw new Error()
      const data = await res.json()
      if (data.error) throw new Error(data.error)
      if (!data.title && !data.description) throw new Error("empty response")

      this.cachedTitle       = data.title
      this.cachedDescription = data.description
      this.applyTranslation()
    } catch {
      this.buttonTarget.disabled = false
      this.buttonTarget.textContent = this.buttonTarget.dataset.translateLabel
    }
  }

  applyTranslation() {
    if (this.cachedTitle       && this.hasTitleTarget)       this.titleTarget.textContent    = this.cachedTitle
    if (this.cachedDescription && this.hasDescriptionTarget) this.descriptionTarget.innerHTML = this.cachedDescription
    this.isTranslated = true
    this.buttonTarget.disabled = false
    this.buttonTarget.textContent = this.buttonTarget.dataset.originalLabel
  }

  showOriginal() {
    if (this.hasTitleTarget)       this.titleTarget.innerHTML       = this.originalTitle
    if (this.hasDescriptionTarget) this.descriptionTarget.innerHTML = this.originalDescription
    this.isTranslated = false
    this.buttonTarget.textContent = this.buttonTarget.dataset.translateLabel
  }
}
