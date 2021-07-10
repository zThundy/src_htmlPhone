import Vue from 'vue'
import App from './App'
import router from './router'
import store from './store'
import VueTimeago from './TimeAgo'
import PhoneAPI from './PhoneAPI'
import Notification from './components/Notification'

Vue.use(VueTimeago)
Vue.use(Notification)
Vue.config.productionTip = false

Vue.prototype.$bus = new Vue()
Vue.prototype.$phoneAPI = PhoneAPI

window.VueTimeago = VueTimeago
window.Vue = Vue
window.store = store

const filter = function (text, length, clamp) {
  clamp = clamp || '...'
  const node = document.createElement('div')
  node.innerHTML = text
  const content = (node.textContent).split('.')
  return content[1].length > length ? `${content[0]}.${content[1].slice(0, length) + clamp}` : content
}

const directive = {
  inserted (el) {
    el.focus()
  }
}
Vue.directive('autofocus', directive)
Vue.filter('truncate', filter)

/* eslint-disable no-new */
window.APP = new Vue({
  el: '#app',
  store,
  router,
  render: h => h(App)
})
