import ColorPicker from 'stimulus-color-picker'

export default class extends ColorPicker {
  connect() {
    if (this.hasButtonTarget) {
      super.connect()
      this.picker
    }
  }

  // Callback when the color is changed
  disconnect() {
    if (this.hasButtonTarget) super.disconnect()
  }

  // Callback when the color is saved
  onSave(color) {
    super.onSave(color)
  }


  get componentOptions() {
    return {
      preview: true,
      hue: true,

      interaction: {
        input: true,
        clear: true,
        save: true,
      },
    }
  }
}