import PhoneAPI from './../../PhoneAPI'
// tutto questo codice è trovabile sulle impostazioni del telefono

const state = {
  closestPlayers: [],
  bluetoothString: 'Spento',
  bluetooth: false
}

const getters = {
  closestPlayers: ({ closestPlayers }) => closestPlayers,
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
      PhoneAPI.requestClosestPlayers(true)
    } else {
      state.bluetoothString = 'Spento'
      PhoneAPI.requestClosestPlayers(false)
    }
    state.bluetooth = bool
  },
  UPDATE_CLOSEST_PLAYERS (state, players) {
    state.closestPlayers = players
  }
}

export default {
  state,
  getters,
  actions,
  mutations
}

if (process.env.NODE_ENV !== 'production') {
  state.closestPlayers = [
    {
      name: 'Giocatore 1',
      id: 1
    },
    {
      name: 'Giocatore 2',
      id: 2
    }
  ]
}
