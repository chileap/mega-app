import { Controller } from "@hotwired/stimulus"
import moment from "moment";

// Connects to data-controller="habits--form"
export default class extends Controller {
  static targets = ["form", "type", "value", "time", "frequency", "formElements", "unitType"]

  submitForm(event){
    // Ignore event if clicked within element
    if (this.formElementsTarget.contains(event.target)) return;
    if (event.target.tagName == 'INPUT' || event.target.className == 'flatpickr-am-pm') {
      return;
    }

    if (this.typeTarget.value != '' && this.timeTarget.value != '' && this.frequencyTarget.value != '' && this.valueTarget.value != '') {
      Rails.fire(this.formTarget, 'submit')
      this.typeTarget.value = 'run'
      this.frequencyTarget.value = 'daily'
      this.timeTarget.value = moment().format('HH:mm')
      this.valueTarget.value = ''
    }
  }
  clear() {
    this.element.reset()
  }
  updateUnitType(event) {
    if (event.target.value == 'run' || event.target.value == 'walk' || event.target.value == 'cycle') {
      this.unitTypeTarget.innerText = 'kilometres'
    } else if (event.target.value == 'drink_water') {
      this.unitTypeTarget.innerText = 'ml'
    } else if (event.target.value == 'no_sugar') {
      this.unitTypeTarget.innerText = 'days'
    } else {
      this.unitTypeTarget.innerText = 'minutes'
    }
  }
  updateHabitEndDate(event) {
    const startDate = this.formTarget.querySelector('#habit_start_date').value;
    this.formTarget.querySelectorAll(".end-type-btn").forEach((btn) => {
      btn.classList.remove('active');
    });
    event.target.classList.add('active');

    switch (event.target.dataset.endType) {
      case 'today':
        const endDate = moment().format('YYYY-MM-DD');
        this.formTarget.querySelector('#habit_end_date')._flatpickr.setDate(endDate);
        break;
      case 'goal-end-date':
        const endDateGoal = event.target.dataset.goalEndDate;
        this.formTarget.querySelector('#habit_end_date')._flatpickr.setDate(endDateGoal);
        break;
      case '30':
        const endDate30 = moment(startDate).add(30, 'days').format('YYYY-MM-DD');
        this.formTarget.querySelector('#habit_end_date')._flatpickr.setDate(endDate30);
        break;
      case '7':
        const endDate7 = moment(startDate).add(7, 'days').format('YYYY-MM-DD');
        this.formTarget.querySelector('#habit_end_date')._flatpickr.setDate(endDate7);
        break;
      case '1':
        const endDate1 = moment(startDate).add(1, 'days').format('YYYY-MM-DD');
        this.formTarget.querySelector('#habit_end_date')._flatpickr.setDate(endDate1);
        break;
      case 'habit-start-date':
        const habitStartDate = moment(startDate).format('YYYY-MM-DD');
        this.formTarget.querySelector('#habit_end_date')._flatpickr.setDate(habitStartDate);
        break;
      default:
        break;
    }
  }
}
