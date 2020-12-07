import PhoneAPI from './../../PhoneAPI'

const state = {
  messages: [],
  unreadMessages: []
}

const getters = {
  messages: ({ messages }) => messages,
  nbMessagesUnread: ({ messages }) => { return messages.filter(e => e.isRead !== 1).length },
  unreadMessages: ({ unreadMessages }) => unreadMessages
}

const actions = {
  setMessages ({ commit }, messages) {
    commit('SET_MESSAGES', messages)
  },
  sendMessage ({ commit }, {phoneNumber, message}) {
    PhoneAPI.sendMessage(phoneNumber, message)
  },
  deleteMessage ({ commit }, { id }) {
    PhoneAPI.deleteMessage(id)
  },
  deleteMessagesNumber ({ commit, state }, { num }) {
    PhoneAPI.deleteMessagesNumber(num)
    commit('SET_MESSAGES', state.messages.filter(mess => {
      return mess.transmitter !== num
    }))
  },
  deleteAllMessages ({ commit }) {
    PhoneAPI.deleteAllMessages()
    commit('SET_MESSAGES', [])
  },
  setMessageRead ({ commit }, num) {
    PhoneAPI.setMessageRead(num)
    commit('SET_MESSAGES_READ', { num })
  },
  resetMessage ({ commit }) {
    commit('SET_MESSAGES', [])
  },
  setupUnreadMessages ({ commit }) {
    commit('UPDATE_UNREAD_MESSAGES', [])
  },
  resetUnreadMessages ({ commit }) {
    commit('RESET_UNREAD_MESSAGES', [])
  }
}

const mutations = {
  UPDATE_UNREAD_MESSAGES (state) {
    for (var val of state.messages) {
      if (val.isRead === 0) {
        if (val.message.length > 20) {
          state.unreadMessages[state.unreadMessages.length] = {
            id: val.id,
            isRead: val.isRead,
            message: val.message,
            transmitter: val.transmitter,
            owner: val.owner,
            time: val.time
          }
          state.unreadMessages[state.unreadMessages.length - 1].message = state.unreadMessages[state.unreadMessages.length - 1].message.substr(0, 22) + '...'
        } else {
          state.unreadMessages[state.unreadMessages.length] = val
        }
      }
    }
  },
  RESET_UNREAD_MESSAGES (state) {
    state.unreadMessages = []
  },
  SET_MESSAGES (state, messages) {
    state.messages = messages
  },
  ADD_MESSAGE (state, message) {
    state.messages.push(message)
  },
  SET_MESSAGES_READ (state, { num }) {
    for (let i = 0; i < state.messages.length; i += 1) {
      if (state.messages[i].transmitter === num && state.messages[i].isRead !== 1) {
        state.messages[i].isRead = 1
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
  const time = new Date().getTime()
  const numRandom = '' + Math.floor(Math.random() * 10000000)
  state.messages = [
    {id: 0, transmitter: '0000', receiver: '06', time: time - 160, message: '#666-123', isRead: 1, owner: 0},
    {id: 1, transmitter: numRandom, receiver: '06', time: time - 160, message: 'Zatutto ?!!!', isRead: 1, owner: 0},
    {id: 2, transmitter: numRandom, time, message: 'Questo è molto fiko?', isRead: 1, owner: 0},
    {id: 3, transmitter: numRandom, time, message: 'Ki sei? ?', isRead: 1, owner: 1},
    {id: 4, transmitter: numRandom, time, message: 'GPS : 244 - 123', isRead: 1, owner: 0},
    {id: 2, transmitter: numRandom, time, message: 'Questo è molto fiko?', isRead: 1, owner: 0},
    {id: 3, transmitter: numRandom, time, message: 'Ki sei? ?', isRead: 1, owner: 1},
    {id: 4, transmitter: numRandom, time, message: 'GPS : 244 - 123', isRead: 1, owner: 0},
    {id: 2, transmitter: numRandom, time, message: 'Questo è molto fiko?', isRead: 1, owner: 0},
    {id: 3, transmitter: numRandom, time, message: 'Ki sei? ?', isRead: 1, owner: 1},
    {id: 4, transmitter: numRandom, time, message: 'GPS : 244 - 123', isRead: 1, owner: 0},
    {id: 2, transmitter: numRandom, time, message: 'Questo è molto fiko?', isRead: 1, owner: 0},
    {id: 3, transmitter: numRandom, time, message: 'Ki sei? ?', isRead: 1, owner: 1},
    {id: 4, transmitter: numRandom, time, message: 'GPS : 244 - 123', isRead: 1, owner: 0},
    {id: 2, transmitter: numRandom, time, message: 'Questo è molto fiko?', isRead: 1, owner: 0},
    {id: 3, transmitter: numRandom, time, message: 'Ki sei? ?', isRead: 1, owner: 1},
    {id: 4, transmitter: numRandom, time, message: 'GPS : 244 - 123', isRead: 1, owner: 0},
    {id: 2, transmitter: numRandom, time, message: 'Questo è molto fiko?', isRead: 1, owner: 0},
    {id: 3, transmitter: numRandom, time, message: 'Ki sei? ?', isRead: 1, owner: 1},
    {id: 4, transmitter: numRandom, time, message: 'GPS : 244 - 123', isRead: 1, owner: 0},
    {id: 2, transmitter: numRandom, time, message: 'Questo è molto fiko?', isRead: 1, owner: 0},
    {id: 3, transmitter: numRandom, time, message: 'Ki sei? ?', isRead: 1, owner: 1},
    {id: 4, transmitter: numRandom, time, message: 'GPS: 244.21, -123.15', isRead: 1, owner: 0},
    {id: 5, transmitter: 'police', time, message: 'Questo è molto fiko?', isRead: 1, owner: 1},
    {id: 6, transmitter: 'ambulance', time, message: 'Ki sei? ?', isRead: 0, owner: 1},
    {id: 7, transmitter: 'test01', time, message: 'Zatutto ?', isRead: 1, owner: 0},
    {id: 8, transmitter: 'test01', time, message: 'questo messaggio è tipo superlunghissimissimissimo e verrà tagliato', isRead: 0, owner: 1},
    {id: 9, transmitter: 'test01', time, message: 'GPS: -1034.5810546875, -2734.1027832031', isRead: 1, owner: 0},
    {id: 44, transmitter: 'test01', time, message: 'https://i.imgur.com/gthahbs.png', isRead: 0, owner: 0},
    {id: 10, transmitter: 'test02', time, message: 'Zatutto ?', isRead: 1, owner: 0},
    {id: 11, transmitter: 'test02', time, message: 'Zatutto ?', isRead: 1, owner: 0},
    {id: 12, transmitter: numRandom, time, message: 'Zatutto ?', isRead: 0, owner: 0},
    {id: 13, transmitter: 'test09', time, message: 'Tu sais pas !', isRead: 1, owner: 0}
  ]
}
