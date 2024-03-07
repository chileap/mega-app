import { Controller } from "@hotwired/stimulus"
import CalendarPopover from "../../services/CalendarPopover";
import CalendarService from "../../services/CalendarService";

// Connects to data-controller="calendar"
export default class extends Controller {
  static targets = ['startTime','endTime', 'dropdown', 'popovercontent', 'popovercontainer']

  connect() {
    this._queryElements();

    this.calendar = CalendarService.init({ calendarEl: this.calendarEl });
    this.calendar.render();

    this._bindToolBarAction();
    this._bindChangeView();
    this._updateViewText();
    this.updateCalendarTitle();
    this.handleListeners();
  }

  toggleCalendarView() {
    this.calendar.refetchEvents();
  }

  handleListeners() {
    const vm = this;
    document.addEventListener('click', function (event) {
      const popoverContainer = document.querySelector('[data-calendars--index-target="popovercontainer"]')
      if (popoverContainer) {
        if (!vm.popovercontainerTarget.contains(event.target) && !vm.popovercontentTarget.contains(event.target)) {
          vm.popovercontentTarget.classList.add('hidden')
        }
      }
    });
  }

  togglePopover(evt) {
    console.log(evt.target);
    if (this.popovercontentTarget.contains(evt.target)) return

    this.popovercontentTarget.classList.toggle('hidden')
  }

  submitEditTaskForm(evt) {
    evt.preventDefault();
    const vm = this;

    const form = evt.target;
    const submitButton = form.querySelector("button[type=submit]");
    const formData = new FormData(form);
    const dueTime = formData.get('task[due_time]');
    const dueDate = formData.get('task[due_date]');

    const taskId = form.dataset.taskId
    const allDay = document.getElementById('task_due_all_day').checked;

    let due_date;

    if (allDay) {
      due_date = `${dueDate} 00:00`;
    } else {
      due_date = `${dueDate} ${dueTime}`;
    }

    formData.append("task[due_date]", due_date);

    Rails.ajax({
      url: `/tasks/${taskId}`,
      type: "PUT",
      dataType: "json",
      data: formData,
      success: (response) => {
        const task = response;

        const event = vm.calendar.getEventById(task.id);
        event.setProp('title', task.title);
        event.setDates(task.start, task.end, {
          allDay: task.allDay
        });
        vm.closePopover();
      },
      error: (response) => {
        console.error(response);
        submitButton.disabled = false;
      }
    });
  }

  submitEditEventForm(evt) {
    evt.preventDefault();
    const vm = this;

    const form = evt.target;
    const submitButton = form.querySelector("button[type=submit]");
    const formData = new FormData(form);
    const startTime = formData.get('event[start_time]');
    const endTime = formData.get('event[end_time]');
    const startDate = formData.get('event[start_date]');
    const endDate = formData.get('event[end_date]');

    console.log(startTime, endTime, startDate, endDate);

    const allDay = document.getElementById('event_all_day').checked;
    const eventId = form.dataset.eventId

    let eventStartDateTime;
    let eventEndDateTime;

    if (allDay) {
      eventStartDateTime = `${startDate} 00:00`;
      eventEndDateTime = `${endDate} 23:59`;
    } else {
      eventStartDateTime = `${startDate} ${startTime}`;
      eventEndDateTime = `${endDate} ${endTime}`;
    }

    formData.append("event[start_time]", eventStartDateTime);
    formData.append("event[end_time]", eventEndDateTime);

    Rails.ajax({
      url: `/events/${eventId}`,
      type: "PUT",
      dataType: "json",
      data: formData,
      success: (response) => {
        const event = vm.calendar.getEventById(response.id);
        event.setProp('title', response.title);
        event.setDates(response.start, response.end, {
          allDay: response.allDay
        });
        vm.closePopover();
      },
      error: (response) => {
        console.error(response);
        submitButton.disabled = false;
      }
    });
  }

  closePopover() {
    CalendarPopover.close();
  }

  toggleAllDayEvent(evt) {
    const eventTimeElement = document.querySelector("#time-event-wrapper");
    if (evt.target.checked) {
      eventTimeElement.classList.add("hidden");
    } else {
      eventTimeElement.classList.remove("hidden");
    }
  }

  toggleDueTime(evt) {
    const dueTimeElement = document.querySelector(".task_due_time");
    if (evt.target.checked) {
      dueTimeElement.classList.add("hidden");
    } else {
      dueTimeElement.classList.remove("hidden");
    }
  }

  _queryElements() {
    this.calendarEl = document.getElementById("calendar");
    this.calendarViewTitle = document.getElementById("calendar-view-text");

    this.dayButton = document.getElementsByClassName("fc-dayGridDay-button");
    this.weekButton = document.getElementsByClassName("fc-dayGridWeek-button");
    this.monthButton = document.getElementsByClassName("fc-dayGridMonth-button");
    this.calendarViewTitle = document.getElementById("calendar-view-text");

    this.prevButton = document.getElementsByClassName("fc-prev-button");
    this.nextButton = document.getElementsByClassName("fc-next-button");
    this.todayButton = document.getElementsByClassName("fc-today-button");

    this.calendarTitle = document.getElementsByClassName("fc-toolbar-title");
  }

  _updateViewText() {
    const calendarView = this.calendar.view.type;
    if (calendarView == "timeGridDay") {
      this.calendarViewTitle.innerHTML = "Daily";
    } else if (calendarView == "timeGridWeek") {
      this.calendarViewTitle.innerHTML = "Weekly";
    } else if (calendarView == "dayGridMonth") {
      this.calendarViewTitle.innerHTML = "Monthly";
    }
  }

  _bindChangeView() {
    const vm = this;
    const dayButton = vm.dayButton;
    const weekButton = vm.weekButton;
    const monthButton = vm.monthButton;
    const search = new URLSearchParams(location.search);

    if (dayButton.length != 0) {
      for (let index = 0; index < dayButton.length; index++) {
        const element = dayButton[index];
        element.addEventListener("click", () => {
          search.set('view', 'daily');
          window.location.search = search.toString();
          this.dropdownTarget.dataset["dropdownOpenValue"] = false
        });
      }
    }

    if (weekButton.length != 0) {
      for (let index = 0; index < weekButton.length; index++) {
        const element = weekButton[index];
        element.addEventListener("click", () => {
          search.set('view', 'weekly');
          window.location.search = search.toString();
          this.dropdownTarget.dataset["dropdownOpenValue"] = false
        });
      }
    }

    if (monthButton.length != 0) {
      for (let index = 0; index < monthButton.length; index++) {
        const element = monthButton[index];
        element.addEventListener("click", () => {
          search.set('view', 'monthly');
          window.location.search = search.toString();
          this.dropdownTarget.dataset["dropdownOpenValue"] = false
        });
      }
    }
  }

  _bindToolBarAction() {
    const vm = this;

    const prevButton = vm.prevButton;
    const nextButton = vm.nextButton;
    const todayButton = vm.todayButton;

    if (prevButton.length != 0) {
      prevButton[0].addEventListener("click", () => {
        vm.calendar.prev();
        vm.updateCalendarTitle();
      });
    }

    if (nextButton.length != 0) {
      nextButton[0].addEventListener("click", () => {
        vm.calendar.next();
        vm.updateCalendarTitle();
      });
    }

    if (todayButton.length != 0) {
      for (let index = 0; index < todayButton.length; index++) {
        const element = todayButton[index];
        element.addEventListener("click", () => {
          vm.calendar.today();
          vm.updateCalendarTitle();
        });
      }
    }
  }

  updateCalendarTitle() {
    this.calendarTitle[0].innerHTML = this.calendar.view.title;
  }

  onEditTaskButton() {
    console.log("edit task button");
  }
}
