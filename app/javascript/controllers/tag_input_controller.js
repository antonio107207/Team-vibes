import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "hidden", "chips"]

  connect() {
    this.tags = this.hiddenTarget.value
      ? this.hiddenTarget.value.split(",").map(t => t.trim()).filter(Boolean)
      : []
    this.render()
  }

  onKey(event) {
    if (event.key === "Enter" || event.key === ",") {
      event.preventDefault()
      this.addCurrent()
    } else if (event.key === "Backspace" && this.inputTarget.value === "") {
      this.tags.pop()
      this.render()
    }
  }

  onBlur() {
    this.addCurrent()
  }

  focusInput() {
    this.inputTarget.focus()
  }

  addCurrent() {
    const raw = this.inputTarget.value
      .trim()
      .replace(/^#+/, "")
      .toLowerCase()
      .replace(/\s+/g, "-")
      .replace(/[^a-z0-9Ѐ-ӿ-]/g, "")
      .slice(0, 32)

    if (raw && !this.tags.includes(raw) && this.tags.length < 10) {
      this.tags.push(raw)
      this.render()
    }
    this.inputTarget.value = ""
  }

  remove(event) {
    const tag = event.currentTarget.dataset.tag
    this.tags = this.tags.filter(t => t !== tag)
    this.render()
  }

  render() {
    this.hiddenTarget.value = this.tags.join(",")
    this.chipsTarget.innerHTML = this.tags.map(tag =>
      `<span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs bg-indigo-100 dark:bg-indigo-900/40 text-indigo-700 dark:text-indigo-300 border border-indigo-200 dark:border-indigo-700">
        #${tag}
        <button type="button" data-tag="${tag}" data-action="click->tag-input#remove"
                class="hover:text-red-500 transition cursor-pointer font-bold leading-none ml-0.5">×</button>
      </span>`
    ).join("")
  }
}
