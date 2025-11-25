import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    timeout: { type: Number, default: 10000 }
  }

  connect() {
    // Auto-fade after timeout
    this.timeoutId = setTimeout(() => {
      this.fadeOut()
    }, this.timeoutValue)
  }

  disconnect() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
    }
  }

  fadeOut() {
    this.element.classList.add('fade-out')
    setTimeout(() => {
      this.element.remove()
    }, 500) // Match the CSS animation duration
  }
}
