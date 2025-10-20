import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "box", "fallback", "dropzone"]

  connect() {
    this.onDrop = this.onDrop.bind(this)
    this.onDragOver = this.onDragOver.bind(this)

    if (this.hasDropzoneTarget) {
      this.dropzoneTarget.addEventListener('dragover', this.onDragOver)
      this.dropzoneTarget.addEventListener('drop', this.onDrop)
      this.dropzoneTarget.addEventListener('click', () => this.inputTarget.click())
      this.dropzoneTarget.addEventListener('keydown', (e) => { if (e.key === 'Enter' || e.key === ' ') this.inputTarget.click() })
    }
  }

  disconnect() {
    if (this.hasDropzoneTarget) {
      this.dropzoneTarget.removeEventListener('dragover', this.onDragOver)
      this.dropzoneTarget.removeEventListener('drop', this.onDrop)
    }
  }

  onDragOver(e) {
    e.preventDefault()
    e.dataTransfer.dropEffect = 'copy'
    this.dropzoneTarget.classList.add('dragover')
  }

  onDrop(e) {
    e.preventDefault()
    this.dropzoneTarget.classList.remove('dragover')
    const dt = e.dataTransfer
    if (!dt || !dt.files || dt.files.length === 0) return
    this.inputTarget.files = dt.files
    this.previewFile(dt.files[0])
  }

  change(e) {
    const f = this.inputTarget.files && this.inputTarget.files[0]
    this.previewFile(f)
  }

  previewFile(file) {
    if (!file) {
      this.boxTarget.hidden = true
      this.fallbackTarget.textContent = 'No file selected'
      return
    }

    const name = file.name
    this.fallbackTarget.textContent = name
    this.boxTarget.innerHTML = ''
    this.boxTarget.hidden = false

    if (file.type.startsWith('image/')) {
      const img = document.createElement('img')
      img.className = 'preview-image'
      img.alt = name
      img.style.maxWidth = '240px'
      img.style.maxHeight = '240px'
      const reader = new FileReader()
      reader.onload = () => { img.src = reader.result }
      reader.readAsDataURL(file)
      this.boxTarget.appendChild(img)
    } else {
      const div = document.createElement('div')
      div.className = 'file-info'
      div.textContent = name
      this.boxTarget.appendChild(div)
    }
  }
}
