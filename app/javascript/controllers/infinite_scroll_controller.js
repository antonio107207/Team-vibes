import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sentinel"]

  initialize() {
    this.loading = false
    this.observer = new IntersectionObserver(
      (entries) => entries.forEach(e => e.isIntersecting && this.loadMore()),
      { rootMargin: "0px 0px 400px 0px" }
    )
  }

  disconnect() {
    this.observer.disconnect()
    this.loading = false
  }

  sentinelTargetConnected(el) {
    this.observer.observe(el)
  }

  sentinelTargetDisconnected(el) {
    this.observer.unobserve(el)
  }

  async loadMore() {
    if (this.loading || !this.hasSentinelTarget) return
    const url = this.sentinelTarget.dataset.url
    if (!url) return

    this.loading = true
    try {
      const res = await fetch(url, {
        headers: { Accept: "text/vnd.turbo-stream.html" }
      })
      if (res.ok) Turbo.renderStreamMessage(await res.text())
    } finally {
      this.loading = false
      // If the new sentinel is already visible (short page), trigger again
      if (this.hasSentinelTarget) {
        const rect = this.sentinelTarget.getBoundingClientRect()
        if (rect.top < window.innerHeight + 400) this.loadMore()
      }
    }
  }
}
