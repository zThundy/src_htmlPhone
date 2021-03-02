import PhoneAPI from './../../PhoneAPI'

const state = {
  darkwebMessages: localStorage['gc_darkweb_messages'] ? JSON.parse(localStorage['gc_darkweb_messages']) : []
}

const getters = {
  darkwebMessages: ({ darkwebMessages }) => darkwebMessages
}

const actions = {
  darkwebPostMessage ({ commit }, message) {
    commit('POST_DARK_MESSAGE', message)
  }
}

const mutations = {
  RECEIVE_DARK_MESSAGES (state, data) {
    state.darkwebMessages = data.messages
    localStorage['gc_darkweb_messages'] = JSON.stringify(state.darkwebMessages)
  },
  POST_DARK_MESSAGE (state, message) {
    state.darkwebMessages.push(message)
    localStorage['gc_darkweb_messages'] = JSON.stringify(state.darkwebMessages)
    PhoneAPI.sendDarkMessage(message)
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
  state.darkwebMessages = [
    {
      message: 'https://wallpaperaccess.com/full/109672.jpg',
      mine: 0
    },
    {
      message: 'this is a message this is a message this is a message this is a message this is a message this is a message this is a message ',
      mine: 1
    },
    {
      message: 'this is a message this is a message this is a message this is a message this is a message this is a message this is a message ',
      mine: 1
    },
    {
      message: 'this is a message this is a message this is a message this is a message this is a message this is a message this is a message ',
      mine: 1
    },
    {
      message: 'this is a message this is a message this is a message this is a message this is a message this is a message this is a message ',
      mine: 1
    },
    {
      message: 'this is a message this is a message this is a message this is a message this is a message this is a message this is a message ',
      mine: 1
    }
  ]
}
