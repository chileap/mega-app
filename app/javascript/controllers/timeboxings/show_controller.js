import { Controller } from "@hotwired/stimulus"
import TimeboxingItemService from "../../services/TimeboxingItemService";
import SortableService from "../../services/SortableService";

// Connects to data-controller="timeboxings--show"
export default class extends Controller {
  connect() {
    this.initTimeboxingCalendar();
    this.initSortableJSToBrainDumpItems();
    this.initSortableJSToTopPriorityItems();
  }

  initSortableJSToBrainDumpItems() {
    const brainDumpItemsEl = document.getElementById('brain-items');

    SortableService.init({
      containerEl: brainDumpItemsEl,
      options: {
        group: {
          name: 'calendar',
          pull: true,
          put: true
        },
        onEnd: (evt) => {
          if (evt.pullMode === "clone" || evt.pullMode) {
            const event = JSON.parse(evt.item.dataset.event);
            const formData = new FormData();
            formData.append("timeboxing_item[priority]", true);

            Rails.ajax({
              url: `/timeboxing_items/${event.id}`,
              type: "PATCH",
              data: formData,
              dataType: "json",
              success: () => {
                window.location.reload();
              }
            });
          }
        }
      }
    });
  }

  initSortableJSToTopPriorityItems() {
    const topPriorityItemsEl = document.getElementById('priority-items');

    SortableService.init({
      containerEl: topPriorityItemsEl,
      options: {
        group: {
          name: 'calendar',
          pull: true,
          put: true
        },
        onEnd: (evt) => {
          if (evt.pullMode === "clone" || evt.pullMode) {
            const event = JSON.parse(evt.item.dataset.event);
            const formData = new FormData();
            formData.append("timeboxing_item[priority]", false);

            Rails.ajax({
              url: `/timeboxing_items/${event.id}`,
              type: "PATCH",
              data: formData,
              dataType: "json",
              success: () => {
                window.location.reload();
              }
            });
          }
        }
      }
    })
  }

  initTimeboxingCalendar() {
    const search = new URLSearchParams(location.search);
    const initialDate = search.has('date') ? search.get('date') : new Date();
    const currentHours = search.has('time') ? search.get('time') : 0;

    this.calendarEl = document.getElementById('calendar');
    this.containerEl = document.getElementById('external-events');
    this.calendar = TimeboxingItemService.init({
      calendarEl: this.calendarEl,
      containerEl: this.containerEl,
      initialDate: initialDate,
      currentHours: currentHours
    })

    this.calendar.render();
  }

  handleInputDateChanged(event) {
    const date = event.target.value;
    const search = new URLSearchParams(location.search);
    search.set('date', date);
    window.location.search = search.toString();
  }

  handleDateChanged(e) {
    const date = e.currentTarget.dataset.date;
    const search = new URLSearchParams(location.search);

    if (search.has('date') && search.get('date') == date) return;
    search.set('date', date);
    window.location.search = search.toString();
  }

  handleTransferNotesToNewDay(evt) {
    const timeboxingId = evt.currentTarget.dataset.timeboxingId;
    const date = evt.target.value;
    const search = new URLSearchParams(location.search);

    if (window.confirm(`Are you sure you want to transfer notes to ${date}?`)) {
      Rails.ajax({
        url: "/timeboxing/transfer_notes",
        type: "PUT",
        data: `date=${date}&timeboxing_id=${timeboxingId}`,
        dataType: "json",
        success: (response) => {
          if (response.success) {
            search.set('date', date);
            window.location.search = search.toString();
          } else {
            console.error(response);
          }
        }
      });
    }
  }

  handleTransferItemToNewDay(evt) {
    const timeboxingId = evt.currentTarget.dataset.timeboxingId;
    const date = evt.target.value;
    const search = new URLSearchParams(location.search);

    if (window.confirm(`Are you sure you want to transfer all uncompleted items to ${date}?`)) {
      Rails.ajax({
        url: "/timeboxing/transfer_items",
        type: "PUT",
        data: `date=${date}&timeboxing_id=${timeboxingId}`,
        dataType: "json",
        success: (response) => {
          if (response.success) {
            search.set('date', date);
            window.location.search = search.toString();
          } else {
            console.error(response);
          }
        }
      });
    }
  }

  completeTimeboxingItem(evt) {
    Rails.fire(evt.target.form, 'submit')
    window.location.reload();
  }

  clear(e) {
    e.preventDefault()
    e.target.reset()
  }

  toggleCompletedAtForm(evt) {
    const form = evt.target.form;
    if (form.querySelector('#timeboxing_item_name').value === "") {
      const completedAtForm = form.querySelector('.timeboxing_item_completed_at');
      if (evt.type === "focus") {
        completedAtForm.classList.remove('hidden');
      } else {
        completedAtForm.classList.add('hidden');
      }
    }

    if (evt.type === "blur" && evt.relatedTarget && evt.relatedTarget.form) {
      const nextElementIsCompletedAtForm = evt.relatedTarget.form.querySelector('.timeboxing_item_completed_at');
      if (nextElementIsCompletedAtForm) nextElementIsCompletedAtForm.classList.remove('hidden');
    }
  }

  handleNotesSuccess(evt) {
    const [data] = evt.detail;
    const form = evt.target;
    form.action =  `/timeboxings/${data.id}`;
    form.querySelector('input[name="_method"]').value = "PATCH";
    const transferNoteArea = document.querySelector('.transfer-notes-action-area');
    transferNoteArea.classList.remove('hidden');

    if (transferNoteArea.firstElementChild.tagName === "A") {
      if (transferNoteArea.firstElementChild.href.includes('timeboxing_id')) {
        transferNoteArea.firstElementChild.href.replace(/timeboxing_id=\d+/, `timeboxing_id=${data.id}`);
      } else {
        transferNoteArea.firstElementChild.href += `&timeboxing_id=${data.id}`;
      }
    } else {
      transferNoteArea.firstElementChild.dataset.timeboxingId = data.id;
    }

    this._setSuccessMessage(evt);
  }

  handleSubmit(evt) {
    evt.preventDefault;
    const form = evt.target;
    let submitTypeInput = form.querySelector('input[name="submitType"]');
    if (!submitTypeInput) {
      submitTypeInput = document.createElement('input');
      submitTypeInput.type = "hidden";
      submitTypeInput.name = "submitType";
      submitTypeInput.value = "autoSave";
      form.appendChild(submitTypeInput);
    }

    if (Object.getPrototypeOf(evt).constructor.name === "SubmitEvent") {
      if (form.querySelector('.autosave-hint')) form.querySelector('.autosave-hint').remove();
      submitTypeInput.value = "manualSave";
    } else {
      submitTypeInput.value = "autoSave";
    }
  }

  handleUpdatePrioritySuccess(evt) {
    const form = evt.target;
    const [data] = evt.detail;
    const listEl = form.parentElement;
    const currentAreaId = listEl.parentElement.id;

    this._setSuccessMessage(evt);
    this.updateRelatedTimeboxingItem(data, currentAreaId);
  }

  handleTimeboxingItemSuccess(evt) {
    const form = evt.target;
    const [data] = evt.detail;
    const listEl = form.parentElement;
    const currentAreaId = listEl.parentElement.id;

    this._updateListItemElement(data, listEl, currentAreaId);
    this._insertDeleteLinkToElement(data, listEl);
    this._insertGoToNextDayLinkToElement(data, listEl)
    this._updateFormToEdit(data, form, currentAreaId);
    document.querySelector('input#timeboxing_id').value = data.timeboxing_id;
    document.querySelector("form#timeboxing-notes-form").action = `/timeboxings/${data.timeboxing_id}`;
    document.querySelector("form#timeboxing-notes-form").querySelector('input[name="_method"]').value = "PATCH";

    const deleteItemsActionArea = document.querySelector('.delete-items-actions');
    deleteItemsActionArea.classList.remove('hidden');
    if (deleteItemsActionArea.firstElementChild.href.includes('timeboxing_id')) {
      deleteItemsActionArea.firstElementChild.href.replace(/timeboxing_id=\d+/, `timeboxing_id=${data.timeboxing_id}`);
    } else {
      deleteItemsActionArea.firstElementChild.href += `?timeboxing_id=${data.timeboxing_id}`;
    }

    const transferActionArea = document.querySelector('.transfer-action-area');
    transferActionArea.classList.remove('hidden');
    if (transferActionArea.firstElementChild.href.includes('timeboxing_id')) {
      transferActionArea.firstElementChild.href.replace(/timeboxing_id=\d+/, `timeboxing_id=${data.timeboxing_id}`);
    } else {
      transferActionArea.firstElementChild.href += `&timeboxing_id=${data.timeboxing_id}`;
    }

    if (data.priority) {
      this.updateRelatedTimeboxingItem(data, currentAreaId);
    }

    this.appendNewFormIfLastItem();
    this.focusOnNewInputAfterEnter(evt);
    this._setSuccessMessage(evt);
  }

  focusOnNewInputAfterEnter(evt) {
    const form = evt.target;
    const submitType = form.querySelector('input[name="submitType"]') ? form.querySelector('input[name="submitType"]').value : "autoSave";
    if (submitType === "manualSave") {
      const nextForm = form.parentElement.nextElementSibling;

      if (nextForm) {
        const nextFormInput = nextForm.querySelector('input[name="timeboxing_item[name]"]');
        if (nextFormInput) nextFormInput.focus();
      }
    }
  }

  handleKeyDownInput(event) {
    if (event.which == 9) {
      event.preventDefault();
      if (event.target.value !== "") {
        this.autoFocusOnNewInputAfterEnter(event.target.closest("form"))
      }
    } else if (event.target.value.length >= 2) {
      this.appenNewFormForTimeboxingItem(event.target.closest("form"));
    }
  }

  appenNewFormForTimeboxingItem(form) {
    const formParentElement = form.parentElement.parentElement;
    if (!form.parentElement.nextElementSibling) {
      const newForm = document.querySelector("#new-item-form-wrapper").firstElementChild.cloneNode(true);
      formParentElement.appendChild(newForm);
    }
  }

  autoFocusOnNewInputAfterEnter(form) {
    const formParentElement = form.parentElement.parentElement;
    const nextFormElement = form.parentElement.nextElementSibling;

    if (nextFormElement) {
      nextFormElement.querySelector("input#timeboxing_item_name").focus();
    } else {
      const newForm = document.querySelector("#new-item-form-wrapper").firstElementChild.cloneNode(true);
      formParentElement.appendChild(newForm);
      newForm.querySelector("input#timeboxing_item_name").focus();
    }
  }

  appendNewFormIfLastItem() {
    const newTimeboxingItemForm = document.querySelectorAll("ul.timeboxing-items");
    newTimeboxingItemForm.forEach((listEl) => {
      const form = listEl.firstElementChild;
      const newTimeboxingItemFormChildren = form.querySelectorAll('.new-timeboxing-form')
      if (newTimeboxingItemFormChildren.length === 0) {
        const newItemForm = document.querySelector("#new-item-form-wrapper").firstElementChild.cloneNode(true);
        if (form.id === "priority-items") newItemForm.querySelector('input[name="timeboxing_item[priority]"]').value = 1;
        form.appendChild(newItemForm)
      }
    })
  }

  updateRelatedTimeboxingItem(response, currentAreaId) {
    let relatedTimeboxingItemId = `#brain-item-${response.id}`;
    let itemEl = document.querySelector(relatedTimeboxingItemId);
    if (currentAreaId === "brain-items") {
      relatedTimeboxingItemId = `#priority-item-${response.id}`;
    } else if (currentAreaId === "priority-items" && !itemEl) {
      this.appendThisItemToBrainDumpList(response);
    }
    itemEl = document.querySelector(relatedTimeboxingItemId);
    itemEl.querySelector('input[name="timeboxing_item[name]"]').value = response.title || response.name;
    itemEl.querySelector('input[name="timeboxing_item[priority]"]').value = response.priority;
  }

  _updateListItemElement(data, listEl, currentAreaId) {
    const newID = currentAreaId.substring(0, currentAreaId.lastIndexOf("s"));

    listEl.id = `${newID}-${data.id}`;
    listEl.classList.remove('new-timeboxing-form');
    listEl.classList.add("fc-event", "w-full", "flex", "flex-row", "items-center", "border-b", "border-gray-200", "focus-within:border-indigo-600")
    listEl.dataset.event = JSON.stringify(data);

    const timeboxingItemAction = listEl.querySelector('.timeboxing-item-action');
    timeboxingItemAction.classList.remove('hidden');
    timeboxingItemAction.classList.add('flex');

    if (data.priority && currentAreaId === "brain-items") {
      timeboxingItemAction.querySelector('.priority-badge').classList.remove('hidden');
    }
  }

  _updateFormToEdit(data, form, currentAreaId) {
    const newID = currentAreaId.substring(0, currentAreaId.lastIndexOf("s"));
    form.id = `${newID}-${data.id}`;
    form.action = `timeboxing_items/${data.id}`;

    form.querySelector('input[name="_method"]').value = "PATCH";
    form.querySelector('input[name="timeboxing_item[timeboxing_id]"]').value = data.timeboxing_id;
    form.querySelector('.timeboxing_item_completed_at').classList.remove('hidden');
    form.querySelector('input[name="timeboxing_item[timeboxing_id]"]').value = data.timeboxing_id;
    form.querySelector('input[name="timeboxing_item[name]"]').value = data.title || data.name;
    form.querySelector('input[name="timeboxing_item[priority]"]').value = data.priority;
  }

  appendThisItemToBrainDumpList(response){
    const brainDumpList = document.querySelector('#brain-items');
    const firstNewItemForm = brainDumpList.querySelector('.new-timeboxing-form');
    const listEl = document.querySelector("#new-item-form-wrapper").firstElementChild.cloneNode(true);
    brainDumpList.insertBefore(listEl, firstNewItemForm);

    this._updateListItemElement(response, listEl, "brain-items");
    this._updateFormToEdit(response, listEl.firstElementChild, "brain-items");
    this._insertDeleteLinkToElement(response, listEl);
    this._insertGoToNextDayLinkToElement(response, listEl);
  }

  _insertGoToNextDayLinkToElement(response, listEl){
    if (listEl.querySelector(".timeboxing-item-action .timeboxing-item-menus .transfer-action")) return;

    const goToNextDayLink = document.createElement('a');
    goToNextDayLink.href = `timeboxing_items/${response.id}/transfer_to_next_day`;
    goToNextDayLink.dataset.method = "patch";
    goToNextDayLink.dataset.confirm = "Are you sure you want to transfer this item to the next day?";
    goToNextDayLink.dataset.turbolinks = "false";
    goToNextDayLink.classList.add(
      "transfer-action",
      "text-orange-500", "group", "flex", "items-center",
      "px-4", "py-2", "text-sm",
      "hover:text-orange-600", "hover:bg-gray-100"
    );
    goToNextDayLink.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" class="fill-none mr-3 h-5 w-5 text-current-color inline-block" role="img" aria-labelledby="aibs2a1oq90vvtmubavfm832op68dcwp"><title id="aibs2a1oq90vvtmubavfm832op68dcwp">Icons/calendar settings</title>
              <path d="M4 10V19C4 20.1046 4.89543 21 6 21H11M4 10V7C4 5.89543 4.89543 5 6 5H18C19.1046 5 20 5.89543 20 7V10H4ZM8 3V7M16 3V7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path>
              <path d="M17.4641 15C18.2043 15 18.8506 15.4021 19.1964 15.9998M17.4641 15C16.7239 15 16.0776 15.4021 15.7318 15.9998M17.4641 15V13M17.4641 21V18.9667M20.9282 15L19.1964 15.9998M14 19L15.7318 18.0002M20.9282 19L19.1965 18.0002M14 15L15.7318 15.9998M15.7318 18.0002C15.5615 17.706 15.4641 17.3644 15.4641 17C15.4641 16.6356 15.5615 16.294 15.7318 15.9998M15.7318 18.0002C16.1255 18.6807 16.7977 18.9802 17.4641 18.9667M17.4641 18.9667C18.1521 18.9529 18.8338 18.6057 19.1965 18.0002M19.1965 18.0002C19.3645 17.7197 19.4641 17.3838 19.4641 17C19.4641 16.6356 19.3667 16.294 19.1964 15.9998" stroke="currentColor" stroke-width="2" stroke-linecap="round"></path>
              </svg> Transfer to Tomorrow`;

    listEl.querySelector(".timeboxing-item-action .timeboxing-item-menus").appendChild(goToNextDayLink)
  }

  _insertDeleteLinkToElement(response, listEl){
    if (listEl.querySelector(".timeboxing-item-action .timeboxing-item-menus .delete-action")) return;

    const deleteLink = document.createElement('a');
    deleteLink.href = `timeboxing_items/${response.id}`;
    deleteLink.dataset.method = "delete";
    deleteLink.dataset.turbolinks = "false";
    deleteLink.classList.add(
      "delete-action",
      "text-red-700", "group", "flex", "items-center",
      "px-4", "py-2", "text-sm",
      "hover:text-red-900", "hover:bg-gray-100"
    );
    deleteLink.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6 fill-none mr-3 h-5 w-5 text-current-color inline-block"><path stroke-linecap="round" stroke-linejoin="round" d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0" /></svg> Delete`;
    listEl.querySelector(".timeboxing-item-action .timeboxing-item-menus").appendChild(deleteLink)
  }

  _setSuccessMessage(evt) {
    const form = evt.target.closest("form");
    form.querySelector(".autosave-message").classList.remove("w-full");
    form.querySelector(".autosave-message").innerHTML = '<i class="fa-regular fa-circle-check text-emerald-400"></i>';

    setTimeout(() => {
      form.querySelector(".autosave-message").innerHTML = "";
    }, 2000);
  }
}
