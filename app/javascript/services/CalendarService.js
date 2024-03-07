import { Calendar } from '@fullcalendar/core';
import rrulePlugin from '@fullcalendar/rrule'
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import listPlugin from '@fullcalendar/list';
import interactionPlugin from '@fullcalendar/interaction';
import moment from 'moment-timezone';

import CalendarPopover from "./CalendarPopover";

const EVENT_COLOR = '#287f58';
const TASK_COLOR = '#1a5284';
const HABIT_COLOR = '#a9a9a9';
const TIMEBOX_COLOR = '#0369a1'

let currentInstance = null;

class CalendarService {
  constructor({calendarEl}) {
    this.calendarEl = calendarEl;
  }

  init() {
    const vm = this;
    let calendarView = 'dayGridMonth';

    const search = new URLSearchParams(location.search);

    if (search.has('view')) {
      switch (search.get('view')) {
        case 'daily':
          calendarView = 'timeGridDay';
          break;
        case 'weekly':
          calendarView = 'timeGridWeek';
          break;
        case 'monthly':
          calendarView = 'dayGridMonth';
          break;
      }
    }

    this.calendar = new Calendar(this.calendarEl, {
      timeZone: 'local',
      plugins: [ rrulePlugin, dayGridPlugin, timeGridPlugin, listPlugin, interactionPlugin ],
      initialView: calendarView,
      selectable: true,
      headerToolbar: false,
      editable: true,
      eventMaxStack: 5,
      dayMaxEvents: true,
      nowIndicator: true,
      eventOrder: '-id',
      aspectRatio:  3 ,
      expandRows: true,
      unselectAuto: false,
      eventOverlap: true,
      views: {
        month: {
          fixedWeekCount: false
        }
      },
      eventTimeFormat: {
        hour: 'numeric',
        minute: 'numeric',
        meridiem: 'short',
        hour12: true
      },
      selectAllow: (selectInfo) => {
        if (this.calendar.view.type === 'dayGridMonth') return true;

        const start_time = moment(selectInfo.startStr).format('YYYY-MM-DD');
        const end_time = moment(selectInfo.endStr).format('YYYY-MM-DD');

        if (start_time === end_time) return true;

        return false;
      },
      events: (info, successCallback, failureCallback) => {
        vm.loadAllCalendarEvents(info, successCallback, failureCallback);
      },
      eventResize: (info) => {
        const { event } = info;
        if (event.id === 'new-entity') return;
        if (event.extendedProps.type === 'habit') return;

        let start_date = event.startStr;
        let end_date = event.endStr;

        if (event.allDay) {
          start_date = moment(event.start).format("YYYY-MM-DD");
          end_date = moment(event.end).subtract(1, 'day').format("YYYY-MM-DD");
        } else {
          start_date = moment.tz(info.event._instance.range.start, 'UTC').format('YYYY-MM-DD HH:mm:ss');
          end_date = moment.tz(info.event._instance.range.end, 'UTC').format('YYYY-MM-DD HH:mm:ss');
        }

        const params = { start_date, end_date, all_day: event.allDay };

        if (event.extendedProps.type === 'tasks') {
          params.task = { id: event.id }
        } else if (event.extendedProps.type === 'events') {
          params.event = { id: event.id }
        }

        vm.updateEvent(params);
      },
      eventDrop: (info) => {
        const { event } = info;
        if (event.id === 'new-entity') return;
        if (event.extendedProps.type === 'habit') return;
        let start_date = event.startStr;
        let end_date = event.endStr;

        if (event.allDay) {
          start_date = moment(event.start).format("YYYY-MM-DD");
          end_date = moment(event.end).subtract(1, 'day').format("YYYY-MM-DD");
        } else {
          start_date = moment.tz(info.event._instance.range.start, 'UTC').format('YYYY-MM-DD HH:mm:ss');
          end_date = moment.tz(info.event._instance.range.end, 'UTC').format('YYYY-MM-DD HH:mm:ss');
        }

        const params = { start_date, end_date, all_day: event.allDay };

        if (event.extendedProps.type === 'tasks') {
          params.task = { id: event.id }
        } else if (event.extendedProps.type === 'events') {
          params.event = { id: event.id }
        }

        vm.updateEvent(params);
      },
      eventClick: (info) => {
        this.removeNewEntityAndCloseExistedPopover();

        CalendarPopover.openDetail({
          element: info.jsEvent.target,
          calendar: this.calendar,
          entity: info.event,
          params: {
            start_date: info.event.start,
            end_date: info.event.end
          }
        });
      },
      unselect: () => {
        console.log('unselect')
      },
      moreLinkClick: () => {
        this.removeNewEntityAndCloseExistedPopover();

        return "popover"
      },
      select: (info) => {
        const startTime = moment(info.startStr).format();
        const endTime = moment(info.endStr).subtract(1, 'day').format();

        if (startTime == endTime && this.calendar.view.type === 'dayGridMonth') return;
        this.removeNewEntityAndCloseExistedPopover();

        this.calendar.addEvent({
          id: 'new-entity',
          title: '(No Title)',
          start: info.startStr,
          end: info.endStr,
          color: EVENT_COLOR,
          extendedProps: {
            type: 'events'
          }
        })
      },
      dateClick: (info) => {
        if (this.calendar.view.type !== 'dayGridMonth') return;
        this.removeNewEntityAndCloseExistedPopover();

        this.calendar.addEvent({
          id: 'new-entity',
          title: '(No Title)',
          start: info.dateStr,
          end: info.dateStr,
          color: EVENT_COLOR,
          allDay: true,
          extendedProps: {
            type: 'events'
          }
        })
      },
      eventDidMount: (info) => {
        const { event, el } = info;
        if (event.id === 'new-entity') {
          CalendarPopover.openNew({
            element: el,
            calendar: this.calendar,
            entity: event,
          });
        }
      },
    });

    return this.calendar;
  }

  updateEvent(params) {
    const vm = this;
    const { start_date, end_date, event, task } = params;

    if (event) {
      const { id } = event;
      const data = new FormData();
      data.append('event[start_time]', start_date);
      data.append('event[end_time]', end_date);
      data.append('event[all_day]', params.all_day);

      Rails.ajax({
        url: `/events/${id}`,
        type: 'PATCH',
        data: data,
        dataType: 'json',
        success: () => {
          vm.calendar.refetchEvents();
        },
        error: () => {
          vm.calendar.refetchEvents();
        }
      })
    } else if (task) {
      const { id } = task;
      const data = new FormData();
      data.append('task[due_date]', start_date);
      data.append('task[due_all_day]', params.all_day);

      Rails.ajax({
        url: `/tasks/${id}`,
        type: 'PATCH',
        dataType: 'json',
        data: data,
        success: () => {
          vm.calendar.refetchEvents();
        },
        error: () => {
          vm.calendar.refetchEvents();
        }
      })
    }
  }

  loadAllCalendarEvents(info, successCallback, failureCallback) {
    const vm = this;
    const calendar_view = document.querySelectorAll("input[name='calendar_view[]']");
    const checkedValue = []
    console.log(calendar_view);
    calendar_view.forEach((item) => {
      if (item.checked) {
        checkedValue.push(item.value);
      }
    })

    let fetchFunctions = [];
    if (checkedValue.includes('events')) {
      fetchFunctions.push(vm._loadEvents(info));
    }
    if (checkedValue.includes('tasks')) {
      fetchFunctions.push(vm._loadTasks(info));
    }
    if (checkedValue.includes('habits')) {
      fetchFunctions.push(vm._loadHabits(info));
    }
    if (checkedValue.includes('timeboxing_items')) {
      fetchFunctions.push(vm._loadTimeboxes(info));
    }

    Promise.all(fetchFunctions).then((response) => {
      let events = [];
      response.forEach((item) => {
        events = events.concat(item);
      })
      successCallback(events);
    }).catch((error) => {
      console.error(error);
      failureCallback(error);
    })
  }

  _loadTimeboxes(info) {
    return new Promise((resolve, reject) => {
      Rails.ajax({
        url: "/timeboxing_items",
        type: "GET",
        dataType: "json",
        data: `start=${info.startStr}&end=${info.endStr}`,
        success: (response) => {
          const new_timeboxes = response.map((timebox) => {
            return {
              id: timebox.id,
              title: timebox.title,
              start: timebox.start,
              end: timebox.end,
              textColor: '#fff',
              color: TIMEBOX_COLOR,
              backgroundColor: TIMEBOX_COLOR,
              editable: false,
              allDay: timebox.allDay,
              extendedProps: {
                type: 'timeboxing_items'
              }
            }
          })
          resolve(new_timeboxes)
        },
        error: (response) => {
          reject(response);
        }
      })
    })
  }

  _loadHabits(info) {
    return new Promise((resolve, reject) => {
      Rails.ajax({
        url: "/habits",
        type: "GET",
        dataType: "json",
        data: `start=${info.startStr}&end=${info.endStr}`,
        success: (response) => {
          console.log(response);
          const new_habits = response.map((habit) => {
            return {
              id: habit.id,
              title: habit.title,
              start: habit.start,
              end: habit.end,
              rrule: habit.rrule,
              textColor: '#fff',
              color: HABIT_COLOR,
              backgroundColor: HABIT_COLOR,
              editable: false,
              allDay: habit.allDay,
              extendedProps: {
                type: 'habits'
              }
            }
          })
          resolve(new_habits)
        },
        error: (response) => {
          console.error(response);
          reject(response)
        }
      });
    })
  }

  _loadEvents(info) {
    return new Promise((resolve, reject) => {
      Rails.ajax({
        url: "/events",
        type: "GET",
        dataType: "json",
        data: `start=${info.startStr}&end=${info.endStr}`,
        success: (response) => {
          console.log(response);
          const new_events = response.map((event) => {
            return {
              id: event.id,
              title: event.title,
              start: event.start,
              end: event.end,
              rrule: event.rrule,
              exdate: event.exdate,
              duration: event.duration,
              textColor: '#fff',
              color: event.color,
              backgroundColor: event.color,
              extendedProps: {
                type: 'events'
              }
            }
          })

          resolve(new_events)
        },
        error: (response) => {
          console.error(response);
          reject(response)
        }
      });
    })
  }

  _loadTasks(info) {
    return new Promise((resolve, reject) => {
      Rails.ajax({
        url: "/tasks",
        type: "GET",
        dataType: "json",
        data: `start=${info.startStr}&end=${info.endStr}`,
        success: (response) => {
          const new_tasks = response.map((task) => {
            return {
              id: task.id,
              title: task.title,
              start: task.start,
              end: task.end,
              duration: "00:30:00",
              textColor: '#fff',
              color: TASK_COLOR,
              backgroundColor: TASK_COLOR,
              extendedProps: {
                type: 'tasks'
              }
            }
          })

          resolve(new_tasks)
        },
        error: (response) => {
          console.error(response);
          reject(response)
        }
      });
    })
  }

  removeNewEntityAndCloseExistedPopover() {
    const new_entity = this.calendar.getEventById('new-entity');
    if (new_entity) new_entity.remove();

    CalendarPopover.close();
  }

}

CalendarService.getCurrentInstance = function() {
  return currentInstance;
}

CalendarService.init = function({ calendarEl }) {
  const instance = new CalendarService({calendarEl});

  currentInstance = instance.init();
  return currentInstance;
}


export default CalendarService;