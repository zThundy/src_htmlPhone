// import PhoneAPI from './../../PhoneAPI'

const state = {
  datiInfo: [{
    current: 0,
    max: 0,
    icon: 'phone',
    suffix: 'Minuti'
  }, {
    current: 0,
    max: 0,
    icon: 'message',
    suffix: 'Messaggi'
  }, {
    current: 0,
    max: 0,
    icon: 'discovery',
    suffix: 'Internet'
  }],
  segnale: 0,
  hasWifi: false
}

const getters = {
  datiInfo: ({ datiInfo }) => datiInfo,
  segnale: ({ segnale }) => segnale
}

const actions = {
  resetDati ({ commit }) {
    commit('SET_DATI_INFO', [])
  },
  getSegnale ({ commit }, { segnale }) {
    commit('SET_SEGNALE', segnale)
  }
}

const mutations = {
  SET_DATI_INFO (state, datiInfo) {
    state.datiInfo = datiInfo
  },
  SET_SEGNALE (state, segnale) {
    state.segnale = segnale
    getters.activeBar = state.activeBar
    getters.nonActiveBar = state.nonActiveBar
  },
  UPDATE_OFFERTA (state, data) {
    for (var key in data.current) {
      state.datiInfo[key].current = Math.floor(data.current[key])
      state.datiInfo[key].max = data.max[key]
    }
  }
}

export default { state, getters, actions, mutations }

if (process.env.NODE_ENV !== 'production') {
  // eslint-disable-next-line
  state.segnale = 0
  state.datiInfo = [{
    current: 500,
    max: 1000,
    icon: 'phone',
    suffix: 'Minuti'
  }, {
    current: 1000,
    max: 2000,
    icon: 'message',
    suffix: 'Messaggi'
  }, {
    current: 0,
    max: 20000,
    icon: 'discovery',
    suffix: 'Internet'
  }]
}
