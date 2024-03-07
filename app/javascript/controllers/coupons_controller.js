import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="coupons"
export default class extends Controller {
  static targets = ["form"]
  connect() {
  }
  submitForm(e){
    Rails.fire(this.formTarget, 'submit')
  }
  clear() {
    console.log('clear form')
    this.element.reset()
  }
}
