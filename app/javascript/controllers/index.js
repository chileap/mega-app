// Load all the controllers within this directory and all subdirectories.
// Controller files must be named *_controller.js.

import { application } from "./application"

import { Dropdown, Modal, Tabs, Popover, Toggle, Slideover } from "tailwindcss-stimulus-components"

application.register('dropdown', Dropdown)
application.register('modal', Modal)
application.register('tabs', Tabs)
application.register('popover', Popover)
application.register('toggle', Toggle)
application.register('slideover', Slideover)

import { Autocomplete } from 'stimulus-autocomplete'
application.register('autocomplete', Autocomplete)

import ColorPicker from './color_picker'
application.register('color-picker', ColorPicker)

import Autosave from './autosave'
application.register('autosave', Autosave)

import Flatpickr from 'stimulus-flatpickr'
application.register('flatpickr', Flatpickr)

import Chart from 'stimulus-chartjs'
application.register('chart', Chart)

// Register each controller with Stimulus
import controllers from "./**/*_controller.js"
controllers.forEach((controller) => {
  application.register(controller.name, controller.module.default)
})
