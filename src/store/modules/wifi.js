// import PhoneAPI from './../../PhoneAPI'
// tutto questo codice è trovabile sulle impostazioni del telefono

const state = {
  retiWifi: [],
  wifiString: 'Non connesso',
  hasWifi: false
}

const getters = {
  retiWifi: ({ retiWifi }) => retiWifi,
  wifiString: ({ wifiString }) => wifiString,
  hasWifi: ({ hasWifi }) => hasWifi
}

const actions = {
  updateWifiString ({ commit }, bool) {
    if (bool) {
      commit('UPDATE_WIFI_STRING', 'Connesso')
    } else {
      commit('UPDATE_WIFI_STRING', 'Non connesso')
    }
  }
}

const mutations = {
  UPDATE_RETI_WIFI (state, retiWifi) {
    state.retiWifi = retiWifi
  },
  UPDATE_WIFI_STRING (state, string) {
    state.wifiString = string
  },
  UPDATE_WIFI (state, bool) {
    state.hasWifi = bool
  }
}

export default {
  state,
  getters,
  actions,
  mutations
}

if (process.env.NODE_ENV !== 'production') {
  state.retiWifi = {
    '1': {
      label: 'rete1',
      password: 'password3'
    },
    '5': {
      label: 'rete2',
      password: 'password5'
    },
    '8': {
      label: 'rete3',
      password: 'password1'
    }
  }
}
