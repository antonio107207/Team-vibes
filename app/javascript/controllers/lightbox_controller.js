import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["thumb"]

  urls = []
  current = 0
  modal = null
  touchStartX = 0

  connect() {
    this.urls = this.thumbTargets.map(t => t.dataset.src)
    if (this.urls.length === 0) return
    this.buildModal()
    document.addEventListener("keydown", this.onKey)
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKey)
    if (this.modal) this.modal.remove()
    document.body.style.overflow = ""
  }

  open(event) {
    this.current = parseInt(event.currentTarget.dataset.index)
    this.modal.classList.remove("hidden")
    this.modal.classList.add("flex")
    document.body.style.overflow = "hidden"
    this.render()
  }

  close() {
    this.modal.classList.add("hidden")
    this.modal.classList.remove("flex")
    document.body.style.overflow = ""
  }

  prev() {
    this.current = (this.current - 1 + this.urls.length) % this.urls.length
    this.render()
  }

  next() {
    this.current = (this.current + 1) % this.urls.length
    this.render()
  }

  render() {
    const img = this.modal.querySelector("[data-lb-img]")
    const spinner = this.modal.querySelector("[data-lb-spinner]")
    const counter = this.modal.querySelector("[data-lb-counter]")
    const prevBtn = this.modal.querySelector("[data-lb-prev]")
    const nextBtn = this.modal.querySelector("[data-lb-next]")

    // Show spinner, hide image during load
    img.style.opacity = "0"
    spinner.classList.remove("hidden")

    const url = this.urls[this.current]
    img.onload = () => {
      spinner.classList.add("hidden")
      img.style.opacity = "1"
    }
    img.src = url

    counter.textContent = `${this.current + 1} / ${this.urls.length}`

    const single = this.urls.length === 1
    prevBtn.classList.toggle("hidden", single)
    nextBtn.classList.toggle("hidden", single)

    // Preload adjacent
    if (this.urls.length > 1) {
      new Image().src = this.urls[(this.current + 1) % this.urls.length]
      new Image().src = this.urls[(this.current - 1 + this.urls.length) % this.urls.length]
    }
  }

  onKey = (e) => {
    if (this.modal.classList.contains("hidden")) return
    if (e.key === "ArrowLeft" || e.key === "ArrowUp") { e.preventDefault(); this.prev() }
    if (e.key === "ArrowRight" || e.key === "ArrowDown") { e.preventDefault(); this.next() }
    if (e.key === "Escape") this.close()
  }

  buildModal() {
    this.modal = document.createElement("div")
    this.modal.className = "fixed inset-0 z-50 hidden items-center justify-center bg-black/95 select-none"

    this.modal.innerHTML = `
      <button data-lb-prev aria-label="Попереднє"
        class="absolute left-3 sm:left-6 top-1/2 -translate-y-1/2 text-white/70 hover:text-white w-11 h-11 flex items-center justify-center rounded-full bg-white/10 hover:bg-white/20 backdrop-blur transition cursor-pointer text-2xl font-light z-10">
        &#8249;
      </button>
      <button data-lb-next aria-label="Наступне"
        class="absolute right-3 sm:right-6 top-1/2 -translate-y-1/2 text-white/70 hover:text-white w-11 h-11 flex items-center justify-center rounded-full bg-white/10 hover:bg-white/20 backdrop-blur transition cursor-pointer text-2xl font-light z-10">
        &#8250;
      </button>
      <button data-lb-close aria-label="Закрити"
        class="absolute top-4 right-4 text-white/70 hover:text-white w-9 h-9 flex items-center justify-center rounded-full bg-white/10 hover:bg-white/20 backdrop-blur transition cursor-pointer z-10">
        ✕
      </button>
      <div data-lb-spinner class="absolute inset-0 flex items-center justify-center pointer-events-none">
        <div class="w-8 h-8 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
      </div>
      <img data-lb-img src="" alt="" draggable="false"
        class="max-h-[90dvh] max-w-[90dvw] sm:max-w-[85dvw] object-contain transition-opacity duration-150 rounded-sm">
      <div data-lb-counter
        class="absolute bottom-5 left-1/2 -translate-x-1/2 text-white/60 text-sm bg-black/40 backdrop-blur px-4 py-1 rounded-full pointer-events-none">
      </div>
    `

    this.modal.querySelector("[data-lb-prev]").addEventListener("click", (e) => { e.stopPropagation(); this.prev() })
    this.modal.querySelector("[data-lb-next]").addEventListener("click", (e) => { e.stopPropagation(); this.next() })
    this.modal.querySelector("[data-lb-close]").addEventListener("click", () => this.close())
    this.modal.addEventListener("click", (e) => { if (e.target === this.modal) this.close() })

    this.modal.addEventListener("touchstart", (e) => {
      this.touchStartX = e.touches[0].clientX
    }, { passive: true })
    this.modal.addEventListener("touchend", (e) => {
      const diff = this.touchStartX - e.changedTouches[0].clientX
      if (Math.abs(diff) > 48) diff > 0 ? this.next() : this.prev()
    }, { passive: true })

    document.body.appendChild(this.modal)
  }
}
