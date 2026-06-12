import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { urls: Array }

  connect() {
    if (!this.hasUrlsValue || !this.urlsValue.length) return
    // Already rendered (Turbo cache restore) — skip re-fetch
    if (this.element.children.length > 0) return
    this.urlsValue.forEach(url => this.load(url))
  }

  async load(url) {
    try {
      const res = await fetch(`/link_preview?url=${encodeURIComponent(url)}`, {
        headers: { Accept: "application/json" }
      })
      if (!res.ok) return
      const data = await res.json()
      if (data.error || !data.title) return
      this.element.insertAdjacentHTML("beforeend", this.card(data, url))
    } catch {}
  }

  card(d, url) {
    const imgWrap = d.image
      ? `<div class="lp-img-wrap overflow-hidden sm:rounded-l-xl rounded-t-xl sm:rounded-t-none">
           <img src="${this.esc(d.image)}" alt=""
                class="w-full h-36 object-cover flex-shrink-0 sm:w-36 sm:h-full"
                loading="lazy" onerror="this.closest('.lp-img-wrap')?.remove()">
         </div>`
      : ""
    const desc = d.description
      ? `<p class="text-xs text-gray-500 dark:text-gray-400 line-clamp-2 mt-0.5">${this.esc(d.description)}</p>`
      : ""
    return `
      <a href="${this.esc(url)}" target="_blank" rel="noopener noreferrer"
         class="flex flex-col sm:flex-row rounded-xl overflow-hidden border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 hover:border-indigo-300 dark:hover:border-indigo-600 transition-colors no-underline mt-2 group"
         style="text-decoration:none">
        ${imgWrap}
        <div class="flex-1 px-3 py-2.5 min-w-0">
          <p class="text-xs font-medium text-gray-400 dark:text-gray-500 mb-0.5 uppercase tracking-wide">${this.esc(d.domain || "")}</p>
          <p class="text-sm font-semibold text-gray-900 dark:text-white line-clamp-2 group-hover:text-indigo-600 dark:group-hover:text-indigo-400 transition-colors">${this.esc(d.title)}</p>
          ${desc}
        </div>
      </a>`
  }

  esc(str) {
    return String(str).replace(/[&<>"']/g, c =>
      ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c])
    )
  }
}
