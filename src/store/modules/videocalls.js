import PhoneAPI from './../../PhoneAPI'

const state = {
  videoCallsHistorique: [],
  videoCallsInfo: null
}

const getters = {
  videoCallsHistorique: ({ videoCallsHistorique }) => videoCallsHistorique,
  videoCallsInfo: ({ videoCallsInfo }) => videoCallsInfo,
  videoCallsDisplayName (state, getters) {
    if (state.videoCallsInfo === null) {
      return 'Errore'
    }
    if (state.videoCallsInfo.hidden === true) {
      return getters.LangString('APP_PHONE_NUMBER_HIDDEN')
    }
    const num = getters.videoCallsDisplayNumber
    const contact = getters.contacts.find(e => e.number === num) || {}
    return contact.display || getters.LangString('APP_PHONE_NUMBER_UNKNOWN')
  },
  videoCallsDisplayNumber (state, getters) {
    if (state.videoCallsInfo === null) {
      return 'Errore'
    }
    if (getters.isInitiatorCall === true) {
      return state.videoCallsInfo.receiver_num
    }
    if (state.videoCallsInfo.hidden === true) {
      return 'Numero nascosco'
    }
    return state.videoCallsInfo.transmitter_num
  },
  isInitiatorCall (state, getters) {
    if (state.videoCallsInfo === null) {
      return false
    }
    return state.videoCallsInfo.initiator === true
  }
}

const actions = {
  startVideoCall ({ commit }, { numero }) {
    PhoneAPI.startVideoCall(numero)
  },
  acceptVideoCall ({ state }) {
    PhoneAPI.acceptVideoCall(state.videoCallsInfo)
  },
  rejectVideoCall ({ state }) {
    PhoneAPI.rejectVideoCall(state.videoCallsInfo)
  },
  ignoreVideoCall ({ commit }) {
    commit('SET_VIDEO_INFO', null)
    PhoneAPI.ignoraChiamata(state.videoCallsInfo)
  },
  deleteVideoPhoneHistory ({ commit, state }, { numero }) {
    PhoneAPI.deletePhoneHistory(numero)
    commit('SET_VIDEO_HISTORIQUE', state.videoCallsHistorique.filter(h => {
      return h.num !== numero
    }))
  },
  deleteAllVideoPhoneHistory ({ commit }) {
    PhoneAPI.deleteAllPhoneHistory()
    commit('SET_VIDEO_HISTORIQUE', [])
  },
  resetVideoCalls ({ commit }) {
    commit('SET_VIDEO_HISTORIQUE', [])
    commit('SET_VIDEO_INFO', null)
  }
}

const mutations = {
  SET_VIDEO_HISTORIQUE (state, videoCallsHistorique) {
    state.videoCallsHistorique = videoCallsHistorique
  },
  SET_VIDEO_INFO_IF_EMPTY (state, videoCallsInfo) {
    if (state.videoCallsInfo === null) {
      state.videoCallsInfo = videoCallsInfo
    }
  },
  SET_VIDEO_INFO (state, videoCallsInfo) {
    state.videoCallsInfo = videoCallsInfo
  },
  SET_VIDEO_INFO_IS_ACCEPTS (state, isAccepts) {
    if (state.videoCallsInfo !== null) {
      state.videoCallsInfo = Object.assign({}, state.videoCallsInfo, {
        is_accepts: isAccepts
      })
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
  state.videoCallsHistorique = [{"id":1,"incoming":0,"num":"336-4557","owner":"336-4557","accepts":0,"time":1528374759000},{"id":2,"incoming":0,"num":"police","owner":"336-4557","accepts":1,"time":1528374787000},{"id":3,"incoming":1,"num":"555-5555","owner":"336-4557","accepts":1,"time":1528374566000},{"id":4,"incoming":1,"num":"555-5555","owner":"336-4557","accepts":0,"time":1528371227000}]
  state.videoCallsInfo = {
    initiator: false,
    id: 5,
    transmitter_src: 5,
    // transmitter_num: '###-####',
    transmitter_num: '5554444',
    receiver_src: undefined,
    // receiver_num: '336-4557',
    receiver_num: '###-####',
    is_valid: 0,
    is_accepts: 0,
    hidden: 0
  }
}
