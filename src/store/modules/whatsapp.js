import PhoneAPI from './../../PhoneAPI'
// import Vue from 'vue'

const state = {
  gruppi: [],
  messaggi: [],
  tempGroupInfo: []
}

const getters = {
  gruppi: ({ gruppi }) => gruppi,
  messaggi: ({ messaggi }) => messaggi,
  tempGroupInfo: ({ tempGroupInfo }) => tempGroupInfo
}

const actions = {
  leaveGroup ({ state, commit }, gruppo) {
    PhoneAPI.abbandonaGruppo(gruppo)
    commit('EXIT_GRUPPO', gruppo)
  },
  requestWhatsappInfo ({ state, commit }, groupId) {
    commit('UPDATE_MESSAGGI', groupId)
  },
  sendMessageInGroup ({ state, commit }, data) {
    PhoneAPI.sendMessageOnGroup(data.message, data.gruppo.id, data.phoneNumber)
  },
  getAllInfoGroups ({state}) {
    PhoneAPI.requestInfoOfGroups()
  },
  updateGroupVars ({ state, commit }, data) {
    commit('UPDATE_GROUP_VARS', data)
  },
  creaGruppo ({ state, commit }, data) {
    PhoneAPI.postCreazioneGruppo(data)
  }
}

const mutations = {
  EXIT_GRUPPO (state, data) {
    state.gruppi = state.gruppi.filter(gruppo => { return gruppo.id !== data.id })
  },
  UPDATE_MESSAGGI (state, groupId) {
    state.messaggi[groupId] = PhoneAPI.requestWhatsappMessaggi(groupId)
  },
  UPDATE_GROUP_VARS (state, data) {
    state.tempGroupInfo[data.key] = data.value
  },
  UPDATE_ALL_GROUPS (state, data) {
    state.gruppi = data
  }
}

export default {
  state,
  getters,
  actions,
  mutations
}

if (process.env.NODE_ENV !== 'production') {
  state.gruppi = [
    {
      id: 1,
      icona: 'https://u.trs.tn/tohqw.jpg',
      gruppo: 'Provo',
      partecipanti: ['5552828', '5552828']
    },
    {
      id: 2,
      gruppo: 'Sto testando',
      partecipanti: ['5554444']
    },
    {
      id: 520,
      gruppo: 'EZ CHAT',
      partecipanti: ['5554444']
    }
  ]
  // Zona messaggi a gruppi //
  state.messaggi['1'] = [
    {
      sender: '5555555',
      message: 'provo il messaggio questo messaggio è superlungo | questo messaggio è superlungo | questo messaggio è superlungo | questo messaggio è superlungo'
    },
    {
      sender: 'developer',
      message: 'provo il messaggio 2'
    }
  ]
  state.messaggi['520'] = [
    {
      sender: '5555555',
      message: 'provo il messaggio questo messaggio è superlungo | questo messaggio è superlungo | questo messaggio è superlungo | questo messaggio è superlungo'
    },
    {
      sender: 'developer',
      message: 'provo il messaggio 2'
    }
  ]
}
