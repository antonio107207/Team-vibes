import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "modal", "cropImage"]

  open() {
    this.inputTarget.click()
  }

  select(event) {
    const file = event.target.files[0]
    if (!file) return

    this.cropImageTarget.src = URL.createObjectURL(file)
    this.modalTarget.classList.remove("hidden")

    this.cropper?.destroy()
    this.cropImageTarget.onload = () => {
      this.cropper = new window.Cropper(this.cropImageTarget, {
        aspectRatio: 1,
        viewMode: 1,
        dragMode: "move",
        autoCropArea: 0.9,
        guides: false,
        center: true,
        highlight: false,
        cropBoxMovable: true,
        cropBoxResizable: true,
        toggleDragModeOnDblclick: false,
      })
    }
  }

  confirm() {
    if (!this.cropper) return
    this.cropper.getCroppedCanvas({ width: 400, height: 400 }).toBlob((blob) => {
      const file = new File([blob], "avatar.jpg", { type: "image/jpeg" })
      const dt = new DataTransfer()
      dt.items.add(file)
      this.inputTarget.files = dt.files
      this.previewTarget.src = URL.createObjectURL(blob)
      this.dismissModal()
    }, "image/jpeg", 0.9)
  }

  close() {
    this.inputTarget.value = ""
    this.dismissModal()
  }

  dismissModal() {
    this.modalTarget.classList.add("hidden")
    this.cropper?.destroy()
    this.cropper = null
  }

  disconnect() {
    this.cropper?.destroy()
  }
}
