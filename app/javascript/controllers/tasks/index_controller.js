import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tasks--index"
export default class extends Controller {
  static targets = ["form", "name","dueDate","notes", "toggle", "flaggedAt", "formElements"]

  completedTask(event) {
    const taskId = event.target.dataset.taskId
    const form = document.getElementById(`form-completed-${taskId}`)

    Rails.fire(form, 'submit')
  }
  submitForm(event){
    // Ignore event if clicked within element
    if (this.formElementsTarget.contains(event.target)) return;

    if (event.target.tagName == 'INPUT' || event.target.className == 'flatpickr-day') {
      return;
    }

    if (this.nameTarget.value != '') {
      Rails.fire(this.formTarget, 'submit')
      this.nameTarget.value = ''
      this.dueDateTarget.parentNode.children[1].value = ''
      this.notesTarget.value = ''
      this.resetFlagged()

      const otherController = this.application.getControllerForElementAndIdentifier(this.toggleTarget, 'toggle')
      otherController.hide(event)
    }
  }
  clear() {
    this.element.reset()
  }
  resetFlagged() {
    const flaggedElement = document.getElementById("flagged")
    const unflaggedElement = document.getElementById("unflagged")

    this.flaggedAtTarget.checked = false
    flaggedElement.classList.add("hidden")
    unflaggedElement.classList.remove("hidden")
  }
  handleToggleFlagged() {
    const flaggedElement = document.getElementById("flagged")
    const unflaggedElement = document.getElementById("unflagged")

    if (this.flaggedAtTarget.checked) {
      flaggedElement.classList.add("hidden")
      unflaggedElement.classList.remove("hidden")
    } else {
      flaggedElement.classList.remove("hidden")
      unflaggedElement.classList.add("hidden")
    }
  }
}
