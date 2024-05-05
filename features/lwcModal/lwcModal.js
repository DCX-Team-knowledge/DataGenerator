import { LightningElement, api } from 'lwc'
import closeLabel from '@salesforce/label/close_label'

export default class lwcModal extends LightningElement {
  @api showModal
  @api modalHeader
  @api modalFooter
  @api removeScroll
  labels = { closeLabel }
  closeLabel = 'Close'

  closeModal() {
    this.dispatchEvent(new CustomEvent('closemodal'))
  }

  handleClick(event) {
    this.dispatchEvent(
      new CustomEvent('buttonclick', {
        detail: { buttonName: event.target.dataset.name },
      })
    )
  }

  get modalHasFooter() {
    return this.modalFooter?.length > 0
  }

  get modalContentClasses() {
    let classes = ['modal-content', 'slds-var-p-around_medium']
    this.removeScroll
      ? classes
      : classes.push('add-scroll')
    return classes.join(' ')
  }
}
