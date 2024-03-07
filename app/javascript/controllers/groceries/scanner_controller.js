import { Controller } from "@hotwired/stimulus"
import { BrowserMultiFormatReader,NotFoundException } from '@zxing/library';

// Connects to data-controller="scanner"
export default class extends Controller {
  static targets = [ 'barcode', 'ingredient']

  connect() {
    console.log("connect")
    this.codeReader = new BrowserMultiFormatReader();
  }

  startScanning() {
    console.log("start scanning")
    this.codeReader.listVideoInputDevices().then((videoInputDevices) => {
      const selectedDeviceId = videoInputDevices[0].deviceId
      this.codeReader.decodeFromVideoDevice(selectedDeviceId, 'video', (result, err) => {
        console.log(result)
        if (result) {
          console.log(result)
          this.fetchGroceryByBarcode(result.text)
        }
        if (err && !(err instanceof NotFoundException)) {
          this.stopScanning()
          console.error(err)
        }
      })
    })
    .catch((err) => {
      this.stopScanning()
      console.error(err)
    })
  }

  stopScanning() {
    console.log("stop scanning")
    this.codeReader.stopStreams()
  }

  fetchGroceryByBarcode(barcode) {
    console.log(barcode)
    this.stopScanning()

    Rails.ajax({
      url: "/groceries/find_by_barcode",
      type: "GET",
      dataType: "json",
      data: `barcode=${barcode}`,
      success: (response) => {
        console.log(response)
        this.stopScanning()
        this.application.getControllerForElementAndIdentifier(this.barcodeTarget, 'modal').close();
        this.ingredientTarget.click()
        document.getElementById('ingredient_grocery_attributes_name').value = response.name
        document.getElementById('ingredient_grocery_id').value = response.id
      },
      error: (response) => {
        console.log(response)
        this.stopScanning()
        this.application.getControllerForElementAndIdentifier(this.barcodeTarget, 'modal').close();
        alert("Barcode not found")
      }
    })
  }
}
