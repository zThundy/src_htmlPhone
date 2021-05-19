// import PhoneAPI from './../../PhoneAPI'
// tutto questo codice è trovabile sulle impostazioni del telefono

const state = {
  bluetoothString: 'Spento',
  bluetooth: false
}

const getters = {
  bluetoothString: ({ bluetoothString }) => bluetoothString,
  bluetooth: ({ bluetooth }) => bluetooth
}

const actions = {
  updateBluetooth ({ state, commit }, bool) {
    commit('UPDATE_BLUETOOTH', bool)
  }
}

const mutations = {
  UPDATE_BLUETOOTH (state, bool) {
    if (bool) {
      state.bluetoothString = 'Acceso'
      // PhoneAPI.requestClosestPlayers(true)
    } else {
      state.bluetoothString = 'Spento'
      // PhoneAPI.requestClosestPlayers(false)
    }
    state.bluetooth = bool
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
