import PhoneAPI from './../../PhoneAPI'
// tutto questo codice è trovabile sulle impostazioni del telefono

const state = {
  bluetooth: false
}

const getters = {
  bluetooth: ({ bluetooth }) => bluetooth
}

const actions = {
  toggleBluetooth ({ commit, state }) {
    commit('TOGGLE_BLUETOOTH')
    PhoneAPI.updateBluetooth(state.bluetooth)
  }
}

const mutations = {
  TOGGLE_BLUETOOTH (state) {
    state.bluetooth = !state.bluetooth
  }
}

export default { state, getters, actions, mutations }

if (process.env.NODE_ENV !== 'production') {
}
