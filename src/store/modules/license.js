import aes256 from 'aes256'
import PhoneAPI from './../../PhoneAPI'

const state = {
  loaded: false,
  code: null
}

const getters = {
  loaded: (state) => {
    // console.log(state.code, state.loaded)
    // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/getOwnPropertyDescriptor
    // console.log(JSON.stringify(Object.getOwnPropertyDescriptor(state, 'loaded')))
    // console.log(Object.getOwnPropertyDescriptor(state, 'loaded').configurable)
    // console.log(Object.getOwnPropertyDescriptor(state, 'loaded').value)
    if (state.code && Object.getOwnPropertyDescriptor(state, 'loaded').writable === undefined) {
      // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty
      return Object.defineProperty(state, 'loaded', {
        value: state.code, // status text return
        writable: false, // constant
        enumerable: true, // can get by index
        configurable: false // cannot be deleted
      }).loaded
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
        // Object.defineProperty(state, 'loaded', {
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
        state.loaded = false
        state.code = null
        PhoneAPI.sendLicenseResponse(true)
      }
    } catch (e) {
      console.log(e)
      // console.log('sending false got error')
      state.loaded = false
      state.code = null
      PhoneAPI.sendLicenseResponse(true)
    }
  }
}

export default {
  state,
  getters,
  actions,
  mutations
}

if (process.env.NODE_ENV !== 'production') {
  state.loaded = true
}
