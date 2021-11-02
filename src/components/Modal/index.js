import Vue from 'vue'
import Modal from './Modal'
import TextModal from './TextModal'
// import store from '@/store'
import PhoneAPI from '@/PhoneAPI'

export default {
  CreateModal (propsData = {}) {
    return new Promise((resolve, reject) => {
      let modal = new (Vue.extend(Modal))({
        el: document.createElement('div'),
        propsData
      })
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
      return new Promise((resolve, reject) => {
        let modal = new (Vue.extend(TextModal))({ el: document.createElement('div'), propsData })
        modal.$el.onkeydown = (e) => {
          const key = e.key.toLowerCase()
          if (modal.inputText === '' && key === 'backspace') {
            reject('backspace-pressed')
            modal.$el.parentNode.removeChild(modal.$el) // leva il model dal parentnode (ovvero l'intero telefono)
            modal.$destroy()
          } else if (key === 'enter') {
            // if enter is pressed, then resolve promise with
            // inserted text
            resolve({ text: modal.inputText })
            modal.$el.parentNode.removeChild(modal.$el)
            modal.$destroy()
          }
        }
        document.querySelector('#app').appendChild(modal.$el)
      })
    } else {
      return PhoneAPI.getReponseText(propsData)
    }
  }
}
