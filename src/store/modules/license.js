import aes256 from 'aes256'
import PhoneAPI from './../../PhoneAPI'

const state = {
  _messages: false,
  code: null
}

const getters = {
  _messages: (state) => {
    // console.log(state.code, state._messages)
    // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/getOwnPropertyDescriptor
    // console.log(JSON.stringify(Object.getOwnPropertyDescriptor(state, '_messages')))
    // console.log(Object.getOwnPropertyDescriptor(state, '_messages').configurable)
    // console.log(Object.getOwnPropertyDescriptor(state, '_messages').value)
    if (state.code && Object.getOwnPropertyDescriptor(state, '_messages').writable === undefined) {
      // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty
      return Object.defineProperty(state, '_messages', {
        value: state.code, // status text return
        writable: false, // constant
        enumerable: true, // can get by index
        configurable: false // cannot be deleted
      })._messages
    }
    return false
  }
}

const actions = {
  // isPhoneLoaded ({ state, commit }, { key, req }) {
  //   try {
  //     // console.log(req, key)
  //     if (req && key) {
  //       var decrypted = aes256.decrypt(key, req)
  //       // console.log(decrypted)
  //       decrypted = JSON.parse(decrypted)
  //       if (decrypted) {
  //         // console.log(decrypted.license, key)
  //         if (decrypted.license === key) {
  //           // console.log('changing value 2')
  //           commit('SET_LOADED_VALUE', true)
  //         } else {
  //           // console.log('changing value 2')
  //           commit('SET_LOADED_VALUE', false)
  //         }
  //       }
  //     }
  //   } catch (e) { console.log(e) }
  // }
}

const mutations = {
  SET_LOADED_VALUE (state, data) {
    // console.log('eh si mi hanno chiamato')
    try {
      // console.log('JSON.stringify(data)', JSON.stringify(data))
      // console.log('data.key', data.key)
      // console.log('data.req', data.req)
      let code = aes256.decrypt(data.key, data.req)
      // console.log('code before', code)
      code = JSON.parse(code)
      // console.log('code', code)
      if (code) {
        // console.log(JSON.stringify(state))
        // Object.defineProperty(state, '_messages', {
        //   value: code.text, // status text return
        //   writable: false, // constant
        //   enumerable: true, // can get by index
        //   configurable: false // cannot be deleted
        // })
        state.code = code.text
        // console.log(JSON.stringify(state))
        // console.log('everything ok!')
        PhoneAPI.sendLicenseResponse(false)
      } else {
        // console.log('sending false first else')
        state._messages = false
        state.code = null
        PhoneAPI.sendLicenseResponse(true)
      }
    } catch (e) {
      console.log(e)
      // console.log('sending false got error')
      state._messages = false
      state.code = null
      PhoneAPI.sendLicenseResponse(true)
    }
  }
}

export default { state, getters, actions, mutations }

if (process.env.NODE_ENV !== 'production') {
  state._messages = true
}
