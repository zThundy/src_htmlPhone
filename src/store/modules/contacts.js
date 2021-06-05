import PhoneAPI from './../../PhoneAPI'

const state = {
  contacts: [],
  defaultContacts: []
}

const getters = {
  contacts: ({ contacts, defaultContacts }) => [...contacts, ...defaultContacts]
}

const actions = {
  updateContactPicture ({ commit }, { id, display, number, icon }) {
    PhoneAPI.updateContactAvatar(id, display, number, icon)
  },
  updateContact (context, { id, display, number, email, icon }) {
    PhoneAPI.updateContact(id, display, number, email, icon)
  },
  addContact (context, { display, number, email, icon }) {
    PhoneAPI.addContact(display, number, email, icon)
  },
  deleteContact (context, {id}) {
    PhoneAPI.deleteContact(id)
  },
  resetContact ({ commit }) {
    commit('SET_CONTACTS', [])
  }
}

const mutations = {
  SET_CONTACTS (state, contacts) {
    state.contacts = contacts.sort((a, b) => a.display.localeCompare(b.display))
  },
  SET_DEFAULT_CONTACTS (state, contacts) {
    state.defaultContacts = contacts
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
  state.contacts = [
    {
      id: 1,
      icon: 'https://i.imgur.com/gthahbs.png',
      number: '5554444',
      display: 'stoprovando :rofl: questo è lungo'
    },
    {
      id: 2,
      icon: 'https://i.imgur.com/1YgvLHK.jpg',
      number: '55529322',
      display: 'questoenuovo'
    },
    {
      id: 3,
      number: '55587422',
      display: 'altrocontatto'
    },
    {
      id: 4,
      number: '55587422',
      display: 'altrocontatto'
    },
    {
      id: 5,
      number: '55587422',
      display: 'altrocontatto',
      email: 'altrocontatto@phone.com'
    },
    {
      id: 6,
      icon: 'https://i.imgur.com/1YgvLHK.jpg',
      number: '55529322',
      display: 'questoenuovo',
      email: 'questoenuovo@phone.com'
    },
    {
      id: 7,
      icon: 'https://i.imgur.com/1YgvLHK.jpg',
      number: '55529322',
      display: 'questoenuovo',
      email: 'questoenuovo@phone.com'
    },
    {
      id: 8,
      icon: 'https://i.imgur.com/1YgvLHK.jpg',
      number: '55529322',
      display: 'questoenuovo',
      email: 'questoenuovo@phone.com'
    },
    {
      id: 9,
      icon: 'https://i.imgur.com/1YgvLHK.jpg',
      number: '55529322',
      display: 'questoenuovo',
      email: 'questoenuovo@phone.com'
    },
    {
      id: 10,
      icon: 'https://i.imgur.com/1YgvLHK.jpg',
      number: '55529322',
      display: 'questoenuovo',
      email: 'questoenuovo@phone.com'
    },
    {
      id: 11,
      icon: 'https://i.imgur.com/1YgvLHK.jpg',
      number: '55529322',
      display: 'questoenuovo',
      email: 'questoenuovo@phone.com'
    }
  ]
}
