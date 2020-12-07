import Vue from 'vue'
import Modal from './Modal'
import TextModal from './TextModal'
// import store from '@/store'
import PhoneAPI from '@/PhoneAPI'

var mandato = false
var mouse = false
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
    if (mouse === false) {
      return PhoneAPI.getReponseText(propsData)
    }
    mandato = false
    return new Promise((resolve, reject) => {
      let modal = new (Vue.extend(TextModal))({
        el: document.createElement('div'),
        propsData
      })
      modal.$el.onkeydown = function (data) {
        if (mandato === false) {
          if (data.which === 8) { // backspace
            mandato = true
            // propsData.onBack()
            reject('UserCancel')
            modal.$el.parentNode.removeChild(modal.$el) // leva il model dal parentnode (ovvero l'intero telefono)
            modal.$destroy()
          } else if (data.which === 13) { // enter
            mandato = true
            // propsData.onEnter(modal.inputText)
            modal.$el.parentNode.removeChild(modal.$el)
            modal.$destroy()
          }
        }
      }

      // modal.$el.getElementByName('modal-textarea').focus()
      setTimeout(() => {
        modal.$refs.textarea.focus()
      }, 1)
      // da qui iniziano eventi e funzioni contenuti
      // nella promise
      document.querySelector('#app').appendChild(modal.$el)
      modal.$on('valid', (data) => {
        resolve(data)
        modal.$el.parentNode.removeChild(modal.$el)
        modal.$destroy()
      })
      modal.$on('cancel', () => {
        reject('UserCancel')
        modal.$el.parentNode.removeChild(modal.$el)
        modal.$destroy()
      })
      modal.cancel = function () {
        reject('UserCancel')
        modal.$el.parentNode.removeChild(modal.$el)
        modal.$destroy()
      }
    })
  }
}
