const state = {
  loaded: false
}

const getters = {
  loaded: ({ loaded }) => loaded
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
  SET_LOADED_VALUE (state, value) {
    // console.log('changing value', value)
    state.loaded = value
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
