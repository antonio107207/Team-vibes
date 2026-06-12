import { Controller } from "@hotwired/stimulus"

// Quill is loaded as window.Quill via a CDN <script> tag in the layout.
export default class extends Controller {
  static targets = ["editor", "input"]

  connect() {
    this.quill = new window.Quill(this.editorTarget, {
      theme: "snow",
      placeholder: this.editorTarget.dataset.placeholder || "",
      modules: {
        toolbar: [
          ["bold", "italic", "underline", "strike"],
          [{ list: "ordered" }, { list: "bullet" }],
          ["link", "blockquote"],
          ["clean"]
        ]
      }
    })

    const existing = this.inputTarget.value
    if (existing && existing.trim()) {
      this.quill.clipboard.dangerouslyPasteHTML(existing)
    }

    this.quill.on("text-change", () => {
      this.inputTarget.value = this.blank() ? "" : this.quill.getSemanticHTML()
    })
  }

  disconnect() {
    this.quill = null
  }

  blank() {
    return this.quill.getText().trim().length === 0
  }
}
