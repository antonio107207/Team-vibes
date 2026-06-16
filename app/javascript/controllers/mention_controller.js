import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown", "list"]

  connect() {
    this.timer       = null
    this.mentionStart = -1
    this.outside = (e) => { if (!this.element.contains(e.target)) this.hide() }
    document.addEventListener("click", this.outside)
  }

  disconnect() {
    document.removeEventListener("click", this.outside)
    clearTimeout(this.timer)
  }

  onInput() {
    const q = this.#query()
    if (q === null) { this.hide(); return }
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.#fetch(q), 180)
  }

  onKeydown(event) {
    if (this.#visible()) {
      if (event.key === "Escape")  { this.hide(); event.stopPropagation() }
      if (event.key === "ArrowDown") { this.#focusItem(0); event.preventDefault() }
    }
  }

  onItemKey(event) {
    const items = [...this.listTarget.querySelectorAll("button")]
    const idx   = items.indexOf(event.currentTarget)
    if (event.key === "ArrowDown")  { items[idx + 1]?.focus(); event.preventDefault() }
    if (event.key === "ArrowUp")    { idx > 0 ? items[idx - 1].focus() : this.inputTarget.focus(); event.preventDefault() }
    if (event.key === "Enter")      { event.currentTarget.click(); event.preventDefault() }
    if (event.key === "Escape")     { this.hide(); this.inputTarget.focus() }
  }

  select(event) {
    const handle = event.currentTarget.dataset.handle
    const input  = this.inputTarget
    const before = input.value.slice(0, this.mentionStart)
    const after  = input.value.slice(input.selectionStart)
    input.value  = `${before}@${handle} ${after}`
    input.focus()
    const pos = before.length + handle.length + 2
    input.setSelectionRange(pos, pos)
    this.hide()
  }

  hide() { this.dropdownTarget.classList.add("hidden") }

  async #fetch(q) {
    const res   = await fetch(`/mentions?q=${encodeURIComponent(q)}`)
    const users = await res.json()
    if (!users.length) { this.hide(); return }
    this.listTarget.innerHTML = users.map(u =>
      `<button type="button"
               class="flex items-center gap-2 w-full px-3 py-2 text-sm text-gray-700 dark:text-gray-200 hover:bg-indigo-50 dark:hover:bg-gray-700 cursor-pointer text-left"
               data-action="click->mention#select keydown->mention#onItemKey"
               data-handle="${u.handle}">
         <img src="${u.avatar}" class="w-6 h-6 rounded-full object-cover shrink-0">
         <span>${u.name}</span>
       </button>`
    ).join("")
    this.dropdownTarget.classList.remove("hidden")
  }

  #query() {
    const input  = this.inputTarget
    const before = input.value.slice(0, input.selectionStart)
    const match  = before.match(/@([\p{L}\p{N}_]*)$/u)
    if (!match) return null
    this.mentionStart = input.selectionStart - match[0].length
    return match[1]
  }

  #visible() { return !this.dropdownTarget.classList.contains("hidden") }
  #focusItem(i) { this.listTarget.querySelectorAll("button")[i]?.focus() }
}
