import PhoneAPI from './../../PhoneAPI'
// tutto questo codice è trovabile sulle impostazioni del telefono

const state = {
  bluetooth: window.localStorage['gc_bluetooth'] || false
}

const getters = {
  bluetooth: ({ bluetooth }) => {
    return Boolean(bluetooth)
  }
}

const actions = {
  toggleBluetooth ({ commit, state }) {
    commit('TOGGLE_BLUETOOTH')
    window.localStorage['gc_bluetooth'] = String(state.bluetooth)
    PhoneAPI.updateBluetooth(state.bluetooth)
  }
}

const mutations = {
  TOGGLE_BLUETOOTH (state) {
    state.bluetooth = Boolean(state.bluetooth)
    state.bluetooth = !state.bluetooth
  }
}

export default {
  state,
  getters,
  actions,
  mutations
}

if (process.env.NODE_ENV !== 'production') {
}
