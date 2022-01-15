import PhoneAPI from './../../PhoneAPI'
const LOCAL_NAME = 'gc_tchat_channels'

const state = {
  channels: JSON.parse(localStorage[LOCAL_NAME] || null) || [],
  currentChannel: null,
  messagesChannel: []
}

const getters = {
  tchatChannels: ({ channels }) => channels,
  tchatCurrentChannel: ({ currentChannel }) => currentChannel,
  tchatMessages: ({ messagesChannel }) => messagesChannel
}

const actions = {
  tchatReset ({commit}) {
    commit('TCHAT_SET_MESSAGES', [])
    commit('TCHAT_SET_CHANNEL', { channel: null })
    commit('TCHAT_REMOVES_ALL_CHANNELS')
  },
  tchatSetChannel ({ state, commit, dispatch }, { channel }) {
    if (state.currentChannel !== channel) {
      commit('TCHAT_SET_MESSAGES', [])
      commit('TCHAT_SET_CHANNEL', { channel })
      dispatch('tchatGetMessagesChannel', { channel })
    }
  },
  tchatAddChannel ({ commit }, { channel }) {
    commit('TCHAT_ADD_CHANNELS', { channel })
  },
  tchatRemoveChannel ({ commit }, { channel }) {
    commit('TCHAT_REMOVES_CHANNELS', { channel })
  },
  tchatGetMessagesChannel ({ commit }, { channel }) {
    PhoneAPI.tchatGetMessagesChannel(channel)
  },
  tchatSendMessage (state, { channel, message }) {
    PhoneAPI.tchatSendMessage(channel, message)
  }
}

const mutations = {
  TCHAT_SET_CHANNEL (state, { channel }) {
    state.currentChannel = channel
  },
  TCHAT_ADD_CHANNELS (state, { channel }) {
    state.channels.push({ channel })
    localStorage[LOCAL_NAME] = JSON.stringify(state.channels)
  },
  TCHAT_REMOVES_CHANNELS (state, { channel }) {
    state.channels = state.channels.filter(c => { return c.channel !== channel })
    localStorage[LOCAL_NAME] = JSON.stringify(state.channels)
  },
  TCHAT_REMOVES_ALL_CHANNELS (state) {
    state.channels = []
    localStorage[LOCAL_NAME] = JSON.stringify(state.channels)
  },
  TCHAT_ADD_MESSAGES (state, message) {
    if (message.channel === state.currentChannel) {
      PhoneAPI.onplaySound({ sound: 'msgnotify.ogg', volume: 0.4, loop: false })
      state.messagesChannel.push(message)
    }
  },
  TCHAT_SET_MESSAGES (state, messages) {
    state.messagesChannel = messages
  }
}

export default { state, getters, actions, mutations }

if (process.env.NODE_ENV !== 'production') {
  state.currentChannel = 'debug'
  state.messagesChannel = JSON.parse('[{"channel":"debug","message":"ehsiilprimomessaggioètroppolungomatipotroppoperchédevoprovarecosasuccedealcontainersescrivounpoema","id":6,"time":1528671680000},{"channel":"debug","message":"Hop","id":5,"time":1528671153000}]')
  for (let i = 0; i < 10; i++) {
    state.messagesChannel.push(Object.assign({}, state.messagesChannel[0], { id: 100 + i, message: 'mess ' + i }))
  }
  state.messagesChannel.push({
    message: 'Message sur plusieur ligne car il faut bien !!! Ok !',
    id: 5000,
    time: new Date().getTime()
  })
  state.messagesChannel.push({
    message: 'Message sur plusieur ligne car il faut bien !!! Ok !',
    id: 5000,
    time: new Date().getTime()
  })
  state.messagesChannel.push({
    message: 'Message sur plusieur ligne car il faut bien !!! Ok !',
    id: 5000,
    time: new Date(4567845).getTime()
  })
  state.messagesChannel.push({
    message: 'Ho scritto un nuovo messaggio superlunghissimissimisisisisisiisimo',
    id: 5000,
    time: new Date(4567845).getTime()
  })
}
