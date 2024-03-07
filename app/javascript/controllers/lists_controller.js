import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lists"
export default class extends Controller {
  static targets = ["form"]
  connect() {
  }
  clear() {
    console.log('clear form')
    this.element.reset()
  }
}
