import { Controller } from "@hotwired/stimulus"
import moment from "moment";

// Connects to data-controller="goals--form"
export default class extends Controller {
  static targets = ["form"]
  connect() {
    this.toggleEndDateOptions();
  }
  toggleEndDateOptions() {
    const startDate = this.formTarget.querySelector('#goal_start_date').value;
    console.log(startDate)
    if (startDate) {
      this.formTarget.querySelector(".end-date-types").classList.remove('hidden');
      this.formTarget.querySelector(".end-date-types").classList.add('flex');
    }
  }
  clear() {
    console.log('clear form')
    this.element.reset()
  }
  updateEndDate(e) {
    let endDate = this.formTarget.querySelector('#goal_end_date').value;
    if (e.target.value) {
      this.formTarget.querySelector(".end-date-types").classList.remove('hidden');
      this.formTarget.querySelector(".end-date-types").classList.add('flex');
    }
    console.log(endDate)

    if (endDate !== "") {
      this.formTarget.querySelectorAll(".end-type-btn").forEach((btn) => {
        btn.classList.remove('active');
      });
      return;
    };
    endDate = moment(e.target.value).add(30, 'days').format('YYYY-MM-DD');
    this.formTarget.querySelector('#goal_end_date')._flatpickr.setDate(endDate);
  }

  updateGoalEndDate(e) {
    const startDate = this.formTarget.querySelector('#goal_start_date').value;
    this.formTarget.querySelectorAll(".end-type-btn").forEach((btn) => {
      btn.classList.remove('active');
    });
    e.target.classList.add('active');

    switch (e.target.dataset.endType) {
      case 'today':
        const endDate = moment().format('YYYY-MM-DD');
        this.formTarget.querySelector('#goal_end_date')._flatpickr.setDate(endDate);
        break;
      case 'goal-start-date':
        this.formTarget.querySelector('#goal_end_date')._flatpickr.setDate(startDate);
        break;
      case '30':
        const endDate30 = moment(startDate).add(30, 'days').format('YYYY-MM-DD');
        this.formTarget.querySelector('#goal_end_date')._flatpickr.setDate(endDate30);
        break;
      case '60':
        const endDate60 = moment(startDate).add(60, 'days').format('YYYY-MM-DD');
        this.formTarget.querySelector('#goal_end_date')._flatpickr.setDate(endDate60);
        break;
      case '90':
        const endDate90 = moment(startDate).add(90, 'days').format('YYYY-MM-DD');
        this.formTarget.querySelector('#goal_end_date')._flatpickr.setDate(endDate90);
        break;
      case '180':
        const endDate180 = moment(startDate).add(180, 'days').format('YYYY-MM-DD');
        this.formTarget.querySelector('#goal_end_date')._flatpickr.setDate(endDate180);
        break;
      case '365' || 'year':
        const endDate365 = moment(startDate).add(365, 'days').format('YYYY-MM-DD');
        this.formTarget.querySelector('#goal_end_date')._flatpickr.setDate(endDate365);
        break;
      case 'end-of-year':
        const endDateEndOfYear = moment(startDate).endOf('year').format('YYYY-MM-DD');
        this.formTarget.querySelector('#goal_end_date')._flatpickr.setDate(endDateEndOfYear);
        break;
      default:
        break;
    }
  }

  updateEndDateToday(startDate) {
    this.formTarget.querySelector('#goal_end_date')._flatpickr.setDate(startDate);
  }
}
