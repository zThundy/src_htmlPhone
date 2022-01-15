const state = {
  retiWifi: [],
  isWifiOn: true,
  hasWifi: false
}

const getters = {
  retiWifi: ({ retiWifi }) => retiWifi,
  hasWifi: ({ hasWifi }) => hasWifi,
  isWifiOn: ({ isWifiOn }) => isWifiOn
}

const actions = {
  toggleWifi ({ commit }, bool) {
    if (!bool) commit('UPDATE_WIFI', bool)
    commit('TOGGLE_WIFI', bool)
  }
}

const mutations = {
  UPDATE_RETI_WIFI (state, retiWifi) {
    state.retiWifi = retiWifi
  },
  UPDATE_WIFI (state, bool) {
    state.hasWifi = bool
  },
  TOGGLE_WIFI (state, bool) {
    state.isWifiOn = bool
  }
}

export default { state, getters, actions, mutations }

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
