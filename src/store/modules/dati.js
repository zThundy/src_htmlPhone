// import PhoneAPI from './../../PhoneAPI'

const state = {
  datiInfo: [{
    label: 'MIN',
    current: 0,
    max: 0
  }, {
    label: 'SMS',
    current: 0,
    max: 0
  }, {
    label: 'MB',
    current: 0,
    max: 0
  }],
  segnale: 0,
  hasWifi: false,
  strokedata: []
}

const getters = {
  datiInfo: ({ datiInfo }) => datiInfo,
  segnale: ({ segnale }) => segnale,
  hasWifi: ({ hasWifi }) => hasWifi,
  strokedata: ({ strokedata }) => strokedata
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
    for (var key in datiInfo) {
      state.strokedata[key] = Math.floor(((state.datiInfo[key].current / state.datiInfo[key].max) * 100))
    }
  },
  SET_SEGNALE (state, segnale) {
    state.segnale = segnale
    getters.activeBar = state.activeBar
    getters.nonActiveBar = state.nonActiveBar
  },
  UPDATE_WIFI (state, hasWifi) {
    state.hasWifi = hasWifi
  },
  UPDATE_OFFERTA (state, data) {
    for (var key in data.current) {
      state.datiInfo[key].current = data.current[key]
      state.datiInfo[key].max = data.max[key]
      if (data.current[key] === 0) {
        state.strokedata[key] = '100'
      } else {
        state.strokedata[key] = Math.floor(((data.current[key] / data.max[key]) * 100))
      }
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
  // eslint-disable-next-line
  state.segnale = 0
  state.datiInfo = [{
    label: 'MIN',
    current: 0,
    max: 1000,
    icon: 'phone'
  }, {
    label: 'SMS',
    current: 24,
    max: 2000,
    icon: 'message'
  }, {
    label: 'MB',
    current: 50,
    max: 20000,
    icon: 'discovery'
  }]
  state.strokedata = [50, 24, 34]
}
