import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="events"
export default class extends Controller {
  static targets = ["form"]
  connect() {
    this.handleToggleDateTime();
    this.handleToggleAllDay();
  }
  submitEventForm(event){
    event.preventDefault();

    const allDayCheckbox = document.getElementById('event_all_day');
    const eventStartDate = document.getElementById("event_start_date").value;
    const eventEndDate = document.getElementById("event_end_date").value;

    let eventStartDateTime;
    let eventEndDateTime;

    if (allDayCheckbox.checked) {
      eventStartDateTime = `${eventStartDate} 00:00`;
      eventEndDateTime = `${eventEndDate} 23:59`;
    } else {
      const eventStartTime = document.getElementById("event_start_time").value;
      const eventEndTime = document.getElementById("event_end_time").value;

      eventStartDateTime = `${eventStartDate} ${eventStartTime}`;
      eventEndDateTime = `${eventEndDate} ${eventEndTime}`;
    }

    document.getElementById("event_start_time").value = eventStartDateTime;
    document.getElementById("event_end_time").value = eventEndDateTime;

    this.formTarget.submit();
  }
  clear() {
    this.element.reset()
  }
  handleToggleDateTime() {
    const allDayCheckbox = document.getElementById('event_all_day');
    const startTime = document.getElementById('event_start_time');
    const endTime = document.getElementById('event_end_time');
    const endDateWrapper = document.getElementById('end-date-wrapper');
    const timeEventWrapper = document.getElementById('time-event-wrapper');

    if (allDayCheckbox === null || startTime === null || endTime === null) return;

    if (allDayCheckbox.checked) {
      endDateWrapper.classList.remove('hidden');
      timeEventWrapper.classList.add('hidden');
    } else {
      endDateWrapper.classList.add('hidden');
      timeEventWrapper.classList.remove('hidden');
    }
  }
  handleToggleAllDay() {
    const allDayCheckbox = document.getElementById('event_all_day');
    const startTime = document.getElementById('event_start_time');
    const endTime = document.getElementById('event_end_time');
    const endDateWrapper = document.getElementById('end-date-wrapper');
    const timeEventWrapper = document.getElementById('time-event-wrapper');

    if (allDayCheckbox === null || startTime === null || endTime === null) return;

    allDayCheckbox.addEventListener('change', () => {
      if (allDayCheckbox.checked) {
        endDateWrapper.classList.remove('hidden');
        timeEventWrapper.classList.add('hidden');
      } else {
        endDateWrapper.classList.add('hidden');
        timeEventWrapper.classList.remove('hidden');
      }
    })
  }
}
