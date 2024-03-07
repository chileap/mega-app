import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="meal_templates"
export default class extends Controller {
  static targets = ["form"]
  connect() {
    console.log("meal_templates_controller")
  }
  search(){
    console.log("searchForm")
  }
}
