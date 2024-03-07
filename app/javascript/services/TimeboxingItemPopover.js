import { createPopper } from "@popperjs/core";

const POPPER_TARGET = "#calendar-popover";
const POPPER_OVERLAY = "#calendar-popover-overlay";

const POPOVER_OPTIONS =       {
  strategy: 'fixed',
  placement: 'bottom',
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
        fallbackPlacements: ['bottom', 'top'],
      },
    },
  ]
};

let currentPopoverInstance = null;

class TimeboxingItemPopover {
  constructor({ element, calendar}) {
    this.element = element;
    this.calendar = calendar;
  }

  openNewForm(params) {
    const queryParams = new URLSearchParams(params);

    Rails.ajax({
      type: "GET",
      url: '/timeboxing_items/new',
      contentType: "application/json",
      data: queryParams.toString(),
      dataType: "script",
      success: ()=>{
        this._initPopper();
        this._listenFormEvents();
      }
    })
  }

  openDetail(entity) {
    Rails.ajax({
      type: "GET",
      url: `/timeboxing_items/${entity.id}`,
      contentType: "application/json",
      dataType: "script",
      success: ()=>{
        this._initPopper();
      }
    })
  }

  close(){
    if(!this.popper) return;

    this.popperInstance.destroy();
    this.popperOverlay.remove();
    this.popper.remove();
    this.popperContainer.remove();
    this.calendar.unselect();
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

  _listenFormEvents(){
    const priorityCheckbox = document.querySelector('input[type=checkbox][name="timeboxing_item[priority]"]');

    if (priorityCheckbox) {
      const currentHighlight = document.querySelector('.fc-highlight');
      priorityCheckbox.addEventListener('change', (evt) => {
        if (evt.target.checked) {
          currentHighlight.style.setProperty('background-color', '#fdba74', 'important');
        } else {
          currentHighlight.style.setProperty('background-color', '#f3f4f6', 'important');
        }
      });
    }
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

  _repositionPopover() {
    if (!this.popperInstance) return;
    this.popperInstance.update();
  }
}

const initTimeboxingItemPopover = ({ element, calendar }) => {
  const instance = new TimeboxingItemPopover({ element, calendar });
  currentPopoverInstance = instance;
  return instance;
}

TimeboxingItemPopover.openNew = function ({ element, calendar, params = {} }) {
  const instance = initTimeboxingItemPopover({ element, calendar })
  instance.openNewForm(params);
  return instance;
}

TimeboxingItemPopover.openDetail = function ({ element, calendar, event}) {
  const instance = initTimeboxingItemPopover({ element, calendar })

  instance.openDetail(event);
  return instance;
}

TimeboxingItemPopover.close = function () {
  if (currentPopoverInstance) {
    currentPopoverInstance.close();
  }
}

export default TimeboxingItemPopover;