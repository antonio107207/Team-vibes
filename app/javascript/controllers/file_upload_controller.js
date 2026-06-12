import { Controller } from "@hotwired/stimulus"
import Cropper from "cropperjs"

export default class extends Controller {
  static targets = ["input", "previews"]

  files = []
  cropper = null
  currentIndex = null
  modal = null

  connect() {
    this.buildModal()
  }

  disconnect() {
    if (this.cropper) this.cropper.destroy()
    if (this.modal) this.modal.remove()
  }

  pick() {
    this.inputTarget.click()
  }

  select(event) {
    Array.from(event.target.files).forEach(file => {
      this.files.push({ file, url: URL.createObjectURL(file), name: file.name, type: file.type })
    })
    event.target.value = ""
    this.render()
    this.syncInput()
  }

  remove(event) {
    const idx = parseInt(event.currentTarget.dataset.index)
    URL.revokeObjectURL(this.files[idx].url)
    this.files.splice(idx, 1)
    this.render()
    this.syncInput()
  }

  openCrop(event) {
    const idx = parseInt(event.currentTarget.dataset.index)
    this.currentIndex = idx

    const img = this.modal.querySelector("[data-crop-img]")
    img.src = ""
    this.modal.classList.remove("hidden")
    this.modal.classList.add("flex")

    if (this.cropper) { this.cropper.destroy(); this.cropper = null }

    img.onload = () => {
      this.cropper = new Cropper(img, { viewMode: 1, autoCropArea: 1, movable: true, zoomable: true })
    }
    img.src = this.files[idx].url
  }

  confirmCrop() {
    if (!this.cropper) return
    this.cropper.getCroppedCanvas({ maxWidth: 2048, maxHeight: 2048 }).toBlob(blob => {
      const old = this.files[this.currentIndex]
      URL.revokeObjectURL(old.url)
      const file = new File([blob], old.name, { type: "image/jpeg" })
      this.files[this.currentIndex] = { file, url: URL.createObjectURL(file), name: file.name, type: file.type }
      this.closeModal()
      this.render()
      this.syncInput()
    }, "image/jpeg", 0.92)
  }

  closeModal() {
    this.modal.classList.add("hidden")
    this.modal.classList.remove("flex")
    if (this.cropper) { this.cropper.destroy(); this.cropper = null }
  }

  render() {
    this.previewsTarget.innerHTML = ""
    if (!this.files.length) return

    const grid = document.createElement("div")
    grid.className = "grid grid-cols-3 gap-2 mb-2"
    this.files.forEach((entry, idx) => grid.appendChild(this.buildCard(entry, idx)))
    this.previewsTarget.appendChild(grid)
  }

  buildCard(entry, idx) {
    const wrap = document.createElement("div")

    if (entry.type.startsWith("image/")) {
      wrap.className = "relative group aspect-square rounded-xl overflow-hidden bg-gray-100 dark:bg-gray-700"
      wrap.innerHTML = `
        <img src="${entry.url}" class="w-full h-full object-cover" alt="" loading="lazy">
        <div class="absolute inset-0 bg-black/0 group-hover:bg-black/50 transition-all flex items-center justify-center gap-2 opacity-0 group-hover:opacity-100">
          <button type="button" data-index="${idx}" data-crop
            class="bg-white/90 text-gray-800 rounded-full w-9 h-9 flex items-center justify-center text-lg cursor-pointer hover:bg-white shadow"
            title="Кадрувати">✂️</button>
          <button type="button" data-index="${idx}" data-del
            class="bg-white/90 text-red-500 rounded-full w-9 h-9 flex items-center justify-center font-bold cursor-pointer hover:bg-white shadow text-sm">✕</button>
        </div>`
      wrap.querySelector("[data-crop]").addEventListener("click", e => this.openCrop({ currentTarget: e.currentTarget }))
      wrap.querySelector("[data-del]").addEventListener("click", e => this.remove({ currentTarget: e.currentTarget }))

    } else if (entry.type.startsWith("audio/")) {
      wrap.className = "col-span-3 bg-gray-50 dark:bg-gray-700 rounded-xl p-3 space-y-2"
      wrap.innerHTML = `
        <div class="flex items-center gap-2">
          <span class="text-base shrink-0">🎵</span>
          <span class="text-sm truncate text-gray-700 dark:text-gray-300 flex-1">${this.esc(entry.name)}</span>
          <button type="button" data-index="${idx}" data-del
            class="shrink-0 text-red-400 hover:text-red-500 cursor-pointer font-bold text-sm leading-none">✕</button>
        </div>
        <audio controls src="${entry.url}" class="w-full accent-indigo-600" style="height:36px"></audio>`
      wrap.querySelector("[data-del]").addEventListener("click", e => this.remove({ currentTarget: e.currentTarget }))

    } else if (entry.type.startsWith("video/")) {
      wrap.className = "col-span-3 rounded-xl overflow-hidden bg-black"
      wrap.innerHTML = `
        <div class="flex items-center gap-2 px-3 py-2 bg-gray-50 dark:bg-gray-700">
          <span class="text-base shrink-0">🎬</span>
          <span class="text-sm truncate text-gray-700 dark:text-gray-300 flex-1">${this.esc(entry.name)}</span>
          <button type="button" data-index="${idx}" data-del
            class="shrink-0 text-red-400 hover:text-red-500 cursor-pointer font-bold text-sm leading-none">✕</button>
        </div>
        <video controls src="${entry.url}" class="w-full max-h-56"></video>`
      wrap.querySelector("[data-del]").addEventListener("click", e => this.remove({ currentTarget: e.currentTarget }))
    }

    return wrap
  }

  syncInput() {
    const dt = new DataTransfer()
    this.files.forEach(e => dt.items.add(e.file))
    this.inputTarget.files = dt.files
  }

  buildModal() {
    this.modal = document.createElement("div")
    this.modal.className = "fixed inset-0 z-50 hidden items-center justify-center bg-black/75 p-4"

    this.modal.innerHTML = `
      <div class="bg-white dark:bg-gray-900 rounded-2xl overflow-hidden w-full max-w-2xl max-h-[90dvh] flex flex-col shadow-2xl">
        <div class="flex items-center justify-between px-4 py-3 border-b border-gray-200 dark:border-gray-700 shrink-0">
          <span class="font-semibold text-gray-800 dark:text-white text-sm">✂️ Кадрувати</span>
          <div class="flex gap-2">
            <button type="button" data-modal-cancel
              class="text-sm px-3 py-1.5 rounded-lg border border-gray-300 dark:border-gray-600 text-gray-600 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 cursor-pointer transition">
              Скасувати
            </button>
            <button type="button" data-modal-confirm
              class="text-sm px-3 py-1.5 rounded-lg bg-indigo-600 text-white hover:bg-indigo-700 cursor-pointer transition font-medium">
              Застосувати
            </button>
          </div>
        </div>
        <div class="flex-1 overflow-hidden min-h-0 bg-gray-900">
          <img data-crop-img src="" alt="" style="max-width:100%;display:block;">
        </div>
      </div>`

    this.modal.querySelector("[data-modal-cancel]").addEventListener("click", () => this.closeModal())
    this.modal.querySelector("[data-modal-confirm]").addEventListener("click", () => this.confirmCrop())
    this.modal.addEventListener("click", e => { if (e.target === this.modal) this.closeModal() })

    document.body.appendChild(this.modal)
  }

  esc(str) {
    return str.replace(/[&<>"']/g, c => ({ "&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;" }[c]))
  }
}
