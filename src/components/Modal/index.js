import Vue from 'vue'
import Modal from './Modal'
import TextModal from './TextModal'
// import store from '@/store'
import PhoneAPI from '@/PhoneAPI'

export default {
  CreateModal (propsData = {}) {
    return new Promise((resolve, reject) => {
      let modal = new (Vue.extend(Modal))({ el: document.createElement('div'), propsData })
      document.querySelector('#app').appendChild(modal.$el)
      modal.$on('select', (data) => {
        resolve(data)
        modal.$el.parentNode.removeChild(modal.$el)
        modal.$destroy()
      })
      modal.$on('cancel', () => {
        resolve({title: 'cancel'})
        modal.$el.parentNode.removeChild(modal.$el)
        modal.$destroy()
      })
    })
  },
  CreateTextModal (propsData = {}) {
    const config = PhoneAPI.config
    if (config.useHTMLTextbox) {
      PhoneAPI.setNUIFocus(true)
      return new Promise((resolve, reject) => {
        let modal = new (Vue.extend(TextModal))({ el: document.createElement('div'), propsData })
        modal.$el.onkeydown = (e) => {
          const key = e.key.toLowerCase()
          if (modal.inputText === '' && key === 'backspace') {
            // this removed the element form the created div
            modal.$el.parentNode.removeChild(modal.$el)
            modal.$destroy()
            // if backspace is pressed and message is empty then
            // close modal with backspace pressed error code
            reject('backspace-pressed')
            // reset nui focus
            PhoneAPI.setNUIFocus(false)
          } else if (key === 'enter') {
            // this removed the element form the created div
            modal.$el.parentNode.removeChild(modal.$el)
            modal.$destroy()
            if (modal.inputText === '') {
              // if enter is pressed and no message is typed then reject with
              // empty message error code
              reject('empty-message')
            } else {
              // if enter is pressed, then resolve promise with
              // inserted text
              resolve({ text: modal.inputText })
            }
            // reset nui focus
            PhoneAPI.setNUIFocus(false)
          }
        }
        // append the modal div element to the main #app div
        document.querySelector('#app').appendChild(modal.$el)
      })
    } else {
      return new Promise((resolve, reject) => {
        const response = PhoneAPI.getReponseText(propsData)
        if (response !== undefined && response.text) {
          resolve(response)
        } else {
          reject('no-text-given')
        }
      })
    }
  }
}
