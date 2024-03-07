import _ from "lodash";
import Rails from "@rails/ujs";
import { Controller } from "@hotwired/stimulus";
const DELAY = 1000;
const ENTER_KEY_CODE = 13;

class AutoSave extends Controller {
  static targets = ['form', 'status']

  connect() {
    this.timeout = null;
    this.autoSave = _.debounce(()=>{
      this.statusTarget.classList.remove('w-full')
      this.statusTarget.innerHTML = '<i class="fa-solid fa-spinner"></i>'
      this.submitForm()
    }, DELAY);
  }

  submitForm(){
    const hintEl = this.formTarget.querySelector('.autosave-hint');
    if (hintEl) hintEl.remove();
    Rails.fire(this.formTarget, "submit");
  }

  save(evt){
    clearTimeout(this.timeout);
    this.autoSave.cancel();

    if (evt.which && evt.which === ENTER_KEY_CODE) {
      return
    }

    if (evt.target.value.length < 3 && evt.target.id != "timeboxing_notes") {
      this.statusTarget.classList.add('w-full')
      this.setStatus('<span class="text-xs text-gray-500">Enter at least 3 characters</span>')
      return
    }

    this.autoSave();
  }

  success(){
    this.statusTarget.classList.remove('w-full')
    this.setStatus('<i class="fa-regular fa-circle-check text-emerald-400"></i>')
  }

  error(e){
    console.log("error", e);
    this.statusTarget.classList.remove('w-full')
    this.setStatus('<i class="fa-solid fa-circle-xmark text-red-500"></i>')
  }

  setStatus(message, {autoclose = true} = {}) {
    this.statusTarget.innerHTML = message

    if (!autoclose) return
    this.timeout = setTimeout(() => {
      this.statusTarget.innerHTML = ''
    }, 2000)
  }
}

export { AutoSave as default };
