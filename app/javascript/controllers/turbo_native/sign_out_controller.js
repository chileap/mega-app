import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  signOut(event) {
    if (this._isTurboNativeApp) {
      event.preventDefault()
      event.stopImmediatePropagation()
      window.TurboNativeBridge.postMessage("signOut")
    }
  }

  deleteWorkspace(event) {
    if (this._isTurboNativeApp) {
      event.preventDefault()
      event.stopImmediatePropagation()
      window.TurboNativeBridge.postMessage("deleteWorkspace")
    }
  }

  get _isTurboNativeApp() {
    return navigator.userAgent.indexOf("Turbo Native") !== -1
  }
}
