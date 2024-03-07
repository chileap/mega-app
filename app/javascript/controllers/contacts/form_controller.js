import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tasks"
export default class extends Controller {
  static targets = ["form", "firstName","lastName", "companyName", "websiteUrl", "address", "formElements"]
  completedTask() {
    Rails.fire(this.formTarget, 'submit')
  }
  submitForm(event){
    // Ignore event if clicked within element
    if (this.formElementsTarget.contains(event.target)) return;

    if (this.firstNameTarget.value != '' || this.lastNameTarget.value != '') {
      Rails.fire(this.formTarget, 'submit')
      this.firstNameTarget.value = ''
      this.lastNameTarget.value = ''
      this.addressTarget.value = ''
      this.websiteUrlTarget.value = ''
      this.companyNameTarget.value = ''
    }
  }
  clear() {
    this.element.reset()
  }
}
