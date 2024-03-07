import { createPopper } from "@popperjs/core";
import moment from "moment";

const POPPER_TARGET = "#calendar-popover";
const POPPER_OVERLAY = "#calendar-popover-overlay";

const POPOVER_OPTIONS =       {
  strategy: 'fixed',
  placement: 'left',
  modifiers: [
    {
      name: 'offset',
      options: {
        offset: [8, 8],
      }
    },
    {
      name: 'preventOverflow',
      options: {
        altAxis: true,
        rootBoundary: 'document',
        enabled: true,
        padding: 10,
        escapeWithReference: false,
      },
    },
    {
      name: 'flip',
      options: {
        fallbackPlacements: ['left', 'bottom', 'top', 'right'],
      },
    },
  ]
};

let currentPopoverInstance = null;

const EVENT_COLOR = '#287f58';
const TASK_COLOR = '#1a5284';

class CalendarPopover {
  constructor({ element, calendar}) {
    this.element = element;
    this.calendar = calendar;
  }

  serializeEvent(entity) {
    const { start, end, startStr, endStr, allDay } = entity
    let start_time;
    let end_time;

    const isSameDay = moment(start).isSame(end, 'day');

    if (allDay && end === null) {
      start_time = moment(start).startOf('day').toString();
      end_time = moment(start).endOf('day').toString();
    } else if (allDay && !isSameDay && end !== null) {
      start_time = moment(start).startOf('day').toString();
      end_time = moment(end).subtract(1, 'day').endOf('day').toString()
    } else {
      start_time = startStr;
      end_time = endStr;
    }

    let name = '';
    let description = '';
    if (entity.extendedProps.type === 'tasks') {
      name = document.getElementById('task_name').value;
      description = document.getElementById('task_notes').value;
    } else if (document.getElementById('event_name')) {
      name = document.getElementById('event_name').value;
      description = document.getElementById('event_description').value;
    }

    return {
      start_time,
      end_time,
      type: entity.extendedProps.type,
      all_day: allDay,
      name,
      description
    }
  }

  openNewForm(entity) {
    const params = this.serializeEvent(entity);
    const queryParams = new URLSearchParams(params);

    Rails.ajax({
      type: "GET",
      url: '/calendars/new',
      data: queryParams.toString(),
      contentType: "application/json",
      dataType: "script",
      success: ()=>{
        this._initPopper();
        this._initFormEvent(entity)
      }
    })
  }

  openEditForm(entity) {
    this.calendarType = entity.extendedProps.type;
    this.entity = entity;
    let dataType = "script";
    let url = `/${this.calendarType}/${this.entity.id}/edit`;

    Rails.ajax({
      type: "GET",
      url: url,
      dataType: dataType,
      success: ()=>{
        this._initPopper();
      }
    })
  }

  openDetail(entity, params) {
    this.calendarType = entity.extendedProps.type;
    this.entity = entity;
    const queryParams = new URLSearchParams(params);

    Rails.ajax({
      type: "GET",
      url: `/${this.calendarType}/${this.entity.id}`,
      data: queryParams.toString(),
      dataType: "script",
      success: ()=>{
        this._initPopper();
        this.listenBtnClick();
      }
    })
  }

  listenBtnClick(params) {
    const vm = this;
    const editBtn = document.getElementById(`edit-btn-${this.entity.id}`);

    if (editBtn) {
      editBtn.addEventListener('click', (evt) => {
        evt.preventDefault();
        CalendarPopover.openEditForm({
          element: vm.element,
          calendar: vm.calendar,
          entity: vm.entity
        });
        vm.close();
      })
    }

    const deleteBtn = document.getElementById(`delete-btn-${this.entity.id}`);

    if (deleteBtn) {
      deleteBtn.addEventListener('click', (evt) => {
        evt.preventDefault();

        let currentElement = evt.target;

        if (evt.target.tagName === 'svg' || evt.target.tagName === 'SVG') {
          const deleteBtn = evt.target.parentElement;
          currentElement = deleteBtn;
        } else if (evt.target.tagName === 'path' || evt.target.tagName === 'PATH') {
          const deleteBtn = evt.target.parentElement.parentElement;
          currentElement = deleteBtn;
        }

        const params = new URLSearchParams({
          start_date: currentElement.dataset.startDate,
          end_date: currentElement.dataset.endDate,
        });

        Rails.ajax({
          type: "GET",
          url: `/${vm.calendarType}/${vm.entity.id}/destroy_modal`,
          data: params.toString(),
          dataType: "script",
          success: ()=>{
            vm.handleDestroyModalButton();
          }
        })

      })
    }
  }

  handleDestroyModalButton() {
    const vm = this;
    const destroySubmitBtn = document.getElementById('destroy-submit-button');

    const closeDeleteModalBtn = document.getElementById('close-btn');

    if (closeDeleteModalBtn) {
      closeDeleteModalBtn.addEventListener('click', (evt) => {
        evt.preventDefault();
        document.querySelector('#destroy-modal').classList.add('hidden');
      })
    }

    if (destroySubmitBtn) {
      destroySubmitBtn.addEventListener('click', (evt) => {
        evt.preventDefault();

        const destroy_method = document.querySelector('input[name="destroy_method"]:checked').value;
        const start_date = document.querySelector('input[name="start_date"]').value;
        const end_date = document.querySelector('input[name="end_date"]').value;

        const params = new URLSearchParams({
          destroy_method: destroy_method,
          start_date: start_date,
          end_date: end_date,
        });

        Rails.ajax({
          type: "DELETE",
          url: `/${vm.calendarType}/${vm.entity.id}/destroy_recurring`,
          data: params.toString(),
          dataType: "json",
          success: (response)=>{
            document.querySelector('#destroy-modal').classList.add('hidden');
            vm.calendar.refetchEvents();
            vm.close();
          }
        })
      })
    }
  }

  close(){
    if(!this.popper) return;

    this.popperInstance.destroy();
    this.popperOverlay.remove();
    this.popper.remove();
    this.popperContainer.remove();
    this.calendar.unselect();

    if (this.entity.id === 'new-entity') {
      this.entity.remove();
    }
  }

  _queryElements(){
    this.popper = document.querySelector(POPPER_TARGET);
    this.popperOverlay = document.querySelector(POPPER_OVERLAY);
    this.popperContainer = document.querySelector('#calendar-popover-container');
    this.arrow = document.getElementById('arrow');
    this.closeButton = document.getElementById('popover-close-button');
  }

  _initPopper(){
    this._queryElements();

    this.popperInstance = createPopper(
      this.element,
      this.popper,
      POPOVER_OPTIONS,
    );
    this._initListeners();
  }

  _initFormEvent(entity) {
    this.entity = entity;
    this.queryEventForms();
    this._handleTabsClick();
    this.handleEventAllDayCheckbox();
    this._handleTaskAllDayCheckbox();
    this.handleEventSubmit();
    this.handleTaskSubmit();
  }

  handleEventSubmit() {
    const vm = this;
    const form = document.getElementById('event-form');
    const submitButton = document.getElementById('event-submit-button');

    if (form === null) return;

    submitButton.addEventListener('click', (evt) => {
      evt.preventDefault();
      submitButton.disabled = true;

      const formData = new FormData(form);
      const startTime = formData.get('event[start_time]');
      const endTime = formData.get('event[end_time]');
      const startDate = formData.get('event[start_date]');
      const endDate = formData.get('event[end_date]');

      const allDay = document.getElementById('event_all_day').checked;

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
        url: "/events",
        type: "POST",
        dataType: "json",
        data: formData,
        success: (response) => {
          vm.close();
          vm.calendar.addEvent({
            id: response.id,
            title: response.title,
            start: response.start,
            end: response.end,
            allDay: response.allDay,
            rrule: response.rrule,
            duration: response.duration,
            textColor: '#fff',
            color: EVENT_COLOR,
            backgroundColor: EVENT_COLOR,
            extendedProps: {
              type: 'events'
            }
          });
        },
        error: (response) => {
          submitButton.disabled = false;
          console.error(response);
        }
      });

    })
  }

  handleTaskSubmit() {
    const vm = this;
    const form = document.getElementById('task-form');
    const submitButton = document.getElementById('task-submit-button');

    if (form === null) return;

    submitButton.addEventListener('click', (event) => {
      event.preventDefault();
      submitButton.disabled = true;

      const formData = new FormData(form);
      const dueTime = formData.get('task[due_time]');
      const dueDate = formData.get('task[due_date]');

      const allDay = document.getElementById('task_due_all_day').checked;

      let due_date;

      if (allDay) {
        due_date = `${dueDate} 00:00`;
      } else {
        due_date = `${dueDate} ${dueTime}`;
      }

      formData.append("task[due_date]", due_date);

      Rails.ajax({
        url: "/tasks",
        type: "POST",
        dataType: "json",
        data: formData,
        success: (response) => {

          vm.close();

          vm.calendar.addEvent({
            id: response.id,
            title: response.title,
            start: response.start,
            end: response.end,
            allDay: response.allDay,
            textColor: '#fff',
            color: TASK_COLOR,
            backgroundColor: TASK_COLOR,
            extendedProps: {
              type: 'tasks'
            }
          });
        },
        error: (response) => {
          console.error(response);
          submitButton.disabled = false;
        }
      });

    })
  }

  _initListeners(){
    this._listenOnOutsideClick();
    this._listenCloseClick();
  }

  _listenOnOutsideClick() {
    this.popperOverlay.addEventListener('click', ()=>{
      this.close();
    });
  }

  _listenCloseClick(){
    this.closeButton.addEventListener('click', () => {
      this.close();
    })
  }

  queryEventForms() {
    this.allDayDueDate = document.getElementById('task_due_all_day');
    this.allDayElement = document.getElementById('event_all_day');
    this.startTime = document.getElementById('event_start_time').value;
    this.endTime = document.getElementById('event_end_time').value;
    this.startDate = document.getElementById('event_start_date').value;
    this.endDate = document.getElementById('event_end_date').value;
    this.taskDueDate = document.getElementById('task_due_date').value;
    this.taskDueTime = document.getElementById('task_due_time').value;

    this.endDateWrapper = document.getElementById('end-date-wrapper');
    this.timeEventWrapper = document.getElementById('time-event-wrapper');
  }

  handleEventAllDayCheckbox() {
    const vm = this;
    if (this.allDayElement === null) return;

    this.allDayElement.addEventListener('change', function(event) {
      vm.entity.setExtendedProp('type', 'events');

      if (event.target.checked) {
        vm._updateEventAllDay();
      } else {
        vm._updateEventNotAllDay();
      }
    })
  }

  _handleTaskAllDayCheckbox() {
    const vm = this;
    if (this.allDayDueDate === null) return;

    this.allDayDueDate.addEventListener('change', function(event) {
      if (event.target.checked) {
        console.log('tasks checked')
        vm._updateTaskAllDay();
      } else {
        vm._updateTaskNotAllDay();
      }

      vm.entity.setExtendedProp('type', 'tasks');
    })
  }

  _updateEventAllDay() {
    const start = moment(this.startDate).format("YYYY-MM-DD");
    const end = moment(this.endDate).add(1, 'day').format("YYYY-MM-DD");

    this.entity.setDates(start, end,
      {
        allDay: true
      }
    )
  }

  _updateEventNotAllDay() {
    const start = moment(`${this.startDate} ${this.startTime}`).format("YYYY-MM-DDTHH:mm:ssZ");
    const end = moment(`${this.endDate} ${this.endTime}`).format("YYYY-MM-DDTHH:mm:ssZ");
    this.entity.setDates(start, end,
      {
        allDay: false
      }
    )
  }

  _updateTaskAllDay() {
    const start = moment(this.taskDueDate).format("YYYY-MM-DD");
    const end = moment(this.taskDueDate).add(1, 'day').format("YYYY-MM-DD");
    this.entity.setDates(start, end,
      {
        allDay: true
      }
    )
  }

  _updateTaskNotAllDay() {
    const start = moment(`${this.taskDueDate} ${this.taskDueTime}`).format("YYYY-MM-DDTHH:mm:ssZ");
    const end = moment(`${this.taskDueDate} ${this.taskDueTime}`).add(30, 'minutes').format("YYYY-MM-DDTHH:mm:ssZ");
    this.entity.setDates(start, end,
      {
        allDay: false
      }
    )
  }

  _handleTabsClick() {
    const vm = this;
    const tabs = document.querySelectorAll('#tabs li')
    if (tabs.length === 0) return;
    this.isSameDay = moment(vm.startDate).isSame(vm.endDate, 'day');

    for (let index = 0; index < tabs.length; index++) {
      const element = tabs[index];

      element.addEventListener('click', function(event) {
        event.preventDefault();
        if (event.target.dataset.tabs === 'task') {
          vm._updateTaskEntity()
        } else {
          vm._updateEventEntity()
        }
      })
    }
  }

  _updateTaskEntity() {
    this.entity.setProp('color', TASK_COLOR);
    this.entity.setExtendedProp('type', 'tasks');
    console.log('update task')

    let start = moment(this.taskDueDate).format("YYYY-MM-DD");
    let end = moment(this.taskDueDate).add(1, 'day').format("YYYY-MM-DD");

    if (this.allDayDueDate.checked) {
      this.entity.setDates(start, end, { allDay: true });
    } else {
      start = moment(`${this.taskDueDate} ${this.taskDueTime}`).format("YYYY-MM-DDTHH:mm:ssZ");
      end = moment(`${this.taskDueDate} ${this.taskDueTime}`).add(30, 'minutes').format("YYYY-MM-DDTHH:mm:ssZ");
      this.entity.setDates(start, end, { allDay: false });
      this.entity.setExtendedProp('type', 'tasks')
    }
  }

  _updateEventEntity() {
    this.entity.setProp('color', EVENT_COLOR);
    this.entity.setExtendedProp('type', 'events');

    let start = moment(this.startDate).format("YYYY-MM-DD");
    let end = moment(this.endDate).add(1, 'day').format("YYYY-MM-DD");

    if (!this.allDayElement.checked) {
      start = moment(`${this.startDate} ${this.startTime}`).format("YYYY-MM-DDTHH:mm:ssZ");
      end = moment(`${this.endDate} ${this.endTime}`).add(1, 'day').format("YYYY-MM-DDTHH:mm:ssZ");
    }

    if (!this.isSameDay) {
      this.entity.setDates( start, end, { allDay: this.allDayElement.checked });
    }
  }

  _repositionPopover() {
    if (!this.popperInstance) return;
    this.popperInstance.update();
  }
}

const initCalendarPopover = ({ element, calendar }) => {
  const instance = new CalendarPopover({ element, calendar });
  currentPopoverInstance = instance;
  return instance;
}

CalendarPopover.openNew = function ({ element, calendar, entity }) {
  const instance = initCalendarPopover({ element, calendar })
  instance.openNewForm(entity);
  return instance;
}

CalendarPopover.openEditForm = function ({ element, calendar, entity }) {
  const instance = initCalendarPopover({ element, calendar })
  instance.openEditForm(entity);
  return instance;
}

CalendarPopover.openDetail = function ({ element, calendar, entity, params = {} }) {
  const instance = initCalendarPopover({ element, calendar })

  instance.openDetail(entity, params);
  return instance;
}

CalendarPopover.close = function () {
  if (currentPopoverInstance) {
    currentPopoverInstance.close();
  }
}

export default CalendarPopover;