import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import interactionPlugin, { ThirdPartyDraggable } from '@fullcalendar/interaction';
import moment from 'moment-timezone';
import TimeboxingItemPopover from "./TimeboxingItemPopover";
import SortableService from './SortableService';

let currentInstance = null;

class TimeboxingItemService {
  constructor({calendarEl}) {
    this.calendarEl = calendarEl;
  }

  init({ containerEl, initialDate, currentHours }) {
    new ThirdPartyDraggable(containerEl, {
      itemSelector: '.fc-event',
      mirrorSelector: ".timeboxing-items-fallback",
      eventData: function(eventEl) {
        const event = JSON.parse(eventEl.dataset.event);
        return {
          title: event.title,
          id: event.id,
          color: event.color,
          backgroundColor: event.color,
          textColor: '#000',
          duration: event.duration
        };
      }
    });

    let scrollTime = currentHours !== 0 ? currentHours + ':00:00' : "08:00:00";
    this.sortable = null;

    this.calendar = new Calendar(this.calendarEl, {
      timeZone: 'local',
      plugins: [ dayGridPlugin, timeGridPlugin, interactionPlugin],
      initialView: 'timeGridDay',
      initialDate: initialDate,
      scrollTime: scrollTime,
      selectable: true,
      headerToolbar: false,
      editable: true,
      droppable: true,
      nowIndicator: true,
      aspectRatio:  3,
      expandRows: true,
      eventOverlap: true,
      unselectAuto: false,
      slotMinTime: "05:00:00",
      slotMaxTime: "24:00:00",
      allDaySlot: false,
      dayHeaders: false,
      slotDuration: "00:30:00",
      slotLabelInterval: "00:30:00",
      slotLabelContent: (arg) => {
        const minute = arg.date.getMinutes();
        if (minute === 0) {
          const timeCalendar = arg.date.toLocaleTimeString('en-US', { hour: 'numeric' });
          return timeCalendar;
        } else {
          return ':30';
        }
      },
      slotLabelDidMount: (arg) => {
        const minute = arg.date.getMinutes();
        if (minute === 0) {
          arg.el.classList.add('font-semibold');
        }
      },
      select: (selectInfo) => {
        let end_time = selectInfo.endStr;
        if (selectInfo.end.getHours() === 0) {
          end_time = moment(selectInfo.endStr).subtract(1, 'seconds').format('YYYY-MM-DDTHH:mm:ssZ');
        }
        const timeboxingId = document.getElementById('timeboxing_id').value;
        TimeboxingItemPopover.openNew({
          element: selectInfo.jsEvent.target,
          calendar: this.calendar,
          params: {
            start: selectInfo.startStr,
            end: end_time,
            time_zone: moment.tz.guess(),
            timeboxing_id: timeboxingId
          }
        });
      },
      eventDidMount: (arg) => {
        const timegridContainer = document.querySelector(".fc-timegrid-col-events")
        arg.el.dataset.event = JSON.stringify({
          id: arg.event.id,
          title: arg.event.title,
          color: arg.event.backgroundColor,
          duration: arg.event.duration,
          start: arg.event.startStr,
          end: arg.event.endStr,
          priority: arg.event.extendedProps.priority,
        });

        this.sortable = SortableService.init({
          containerEl: timegridContainer,
          options: {
            group: {
              name: 'calendar',
              pull: true,
              put: true
            },
            draggable: ".fc-timegrid-event-harness",
            sort: false,
            onEnd: (evt) => {
              if (evt.pullMode) {
                const event = JSON.parse(evt.item.firstElementChild.dataset.event);
                const start = (evt.to.id === "priority-items") ? moment(event.start).format('YYYY-MM-DDTHH:mm:ssZ') : null;
                const end = (evt.to.id === "priority-items") ? moment(event.end).format('YYYY-MM-DDTHH:mm:ssZ') : null;
                this._updateTimeboxingItem({
                  id: event.id,
                  startStr: start,
                  endStr: end,
                  priority: evt.to.id === "priority-items" ? 1 : event.priority
                });
              }
            }
          }
        });
      },
      eventContent: (arg) => {
        const event = arg.event;
        const time = moment(event.start).format('h:mm a') + ' - ' + moment(event.end).format('h:mm a');
        const title = event.title;
        const color = event.borderColor;
        const textDecor = event.extendedProps.completed ? 'line-through' : 'none';

        const html = `
          <div class="flex items-center">
            <div class="w-2 h-2 rounded-full mr-2" style="background-color: ${color}"></div>
            <div class="flex-1 ${textDecor}" style="color: #000">
              <div class="text-sm font-semibold">${title}</div>
              <div class="text-xs">${time}</div>
            </div>
          </div>
        `;
        return { html: html };
      },
      eventClick: (info) => {
        this.calendar.unselect();

        const event = info.event;
        TimeboxingItemPopover.openDetail({
          element: info.jsEvent.target,
          calendar: this.calendar,
          event: event
        });
      },
      events: (info, successCallback, failureCallback) => {
        Promise.all([this._loadTimeboxingItems(info)]).then(([timeboxing_items]) => {
          successCallback(timeboxing_items);
        }).catch((error) => {
          console.error(error);
          failureCallback(error);
        })
      },
      eventResizeStart: () => {
        if (!this.sortable) return;
        this.sortable.option('disabled', true);
      },
      eventResize: (info) => {
        const event = info.event;
        this._updateTimeboxingItem(event);
      },
      eventDrop: (info) => {
        const event = info.event;
        const target = info.jsEvent.target;
        if (this.isBrainDumpArea(target)) return;
        this._updateTimeboxingItem(event);
      },
      drop: (info) => {
        const event = JSON.parse(info.draggedEl.dataset.event);
        const end_time = moment(info.dateStr).add(30, "minutes").format('YYYY-MM-DDTHH:mm:ssZ');

        this._updateTimeboxingItem({
          id: event.id,
          startStr: info.dateStr,
          endStr: end_time,
          priority: event.priority
        });
      },
    });

    return this.calendar;
  }

  isSVG(target) {
    return target.tagName === "svg" || target.tagName === "path";
  }

  isBrainDumpArea(target) {
    return target.form || target.tagName === "INPUT" || target.tagName === "LI" || target.tagName === "SPAN" || this.isSVG(target);
  }

  _loadTimeboxingItems(info) {
    const timeboxingId = document.getElementById('timeboxing_id').value;
    return new Promise((resolve, reject) => {
      Rails.ajax({
        url: "/timeboxing_items",
        type: "GET",
        dataType: "json",
        data: `start=${info.startStr}&end=${info.endStr}&timeboxing_id=${timeboxingId}`,
        success: (response) => {
          const timeboxing_items = response.map((item) => {
            return {
              id: item.id,
              title: item.title,
              start: item.start,
              end: item.end,
              color: item.color,
              backgroundColor: item.backgroundColor,
              textColor: item.textColor,
              extendedProps: {
                type: 'timeboxing',
                completed: item.completed,
                priority: item.priority
              }
            }
          })

          resolve(timeboxing_items)
        },
        error: (response) => {
          console.error(response);
          reject(response)
        }
      });
    })
  }

  _updateTimeboxingItem(event) {
    const formData = new FormData();
    const priority = event.priority ? event.priority : (event.extendedProps ? event.extendedProps.priority : 0);

    formData.append('timeboxing_item[start_time]', event.startStr);
    formData.append('timeboxing_item[end_time]', event.endStr);
    formData.append('timeboxing_item[time_zone]', moment.tz.guess());
    formData.append('timeboxing_item[priority]', priority);

    Rails.ajax({
      url: `/timeboxing_items/${event.id}`,
      type: "PATCH",
      data: formData,
      dataType: "json",
      success: () => {
        window.location.reload();
      },
      error: (response) => {
        console.error(response);
      }
    });
  }
}

TimeboxingItemService.getCurrentInstance = function() {
  return currentInstance;
}

TimeboxingItemService.init = function({ calendarEl, containerEl, initialDate, currentHours = 0 }) {
  const instance = new TimeboxingItemService({calendarEl});

  currentInstance = instance.init({ containerEl, initialDate, currentHours });
  return currentInstance;
}

export default TimeboxingItemService;
