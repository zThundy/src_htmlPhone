const state = {
  contacts: [],
  defaultContacts: []
}

const getters = {
  contacts: ({ contacts, defaultContacts }) => [...contacts, ...defaultContacts]
}

const actions = {
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

export default { state, getters, actions, mutations }

if (process.env.NODE_ENV !== 'production') {
  const generateRandomInteger = (max) => {
    return String(Math.floor(Math.random() * max) + 1)
  }
  const makeid = (length) => {
    var result = []
    var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    var charactersLength = characters.length
    for (var i = 0; i < length; i++) {
      result.push(characters.charAt(Math.floor(Math.random() * charactersLength)))
    }
    return result.join('')
  }
  // eslint-disable-next-line
  state.contacts = [
    {
      id: 1,
      icon: 'https://i.imgur.com/gthahbs.png',
      number: '555' + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9),
      display: 'stoprovando :rofl: questo è lungo'
    },
    {
      id: 2,
      icon: 'https://i.imgur.com/1YgvLHK.jpg',
      number: '555' + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9),
      display: 'questoenuovo'
    },
    {
      id: 3,
      number: '555' + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9),
      display: 'altrocontatto'
    },
    {
      id: 4,
      number: '555' + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9),
      display: 'altrocontatto'
    },
    {
      id: 5,
      number: '555' + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9),
      display: makeid(20)
    },
    {
      id: 6,
      number: '555' + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9),
      display: makeid(20)
    },
    {
      id: 7,
      number: '555' + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9),
      display: makeid(20)
    },
    {
      id: 8,
      number: '555' + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9),
      display: makeid(20)
    },
    {
      id: 9,
      number: '555' + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9),
      display: makeid(20)
    },
    {
      id: 10,
      number: '555' + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9),
      display: makeid(20)
    },
    {
      id: 11,
      number: '555' + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9),
      display: makeid(20)
    },
    {
      id: 12,
      number: '555' + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9),
      display: makeid(20)
    },
    {
      id: 13,
      number: '555' + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9),
      display: makeid(20)
    },
    {
      id: 14,
      number: '555' + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9) + generateRandomInteger(9),
      display: makeid(20)
    }
  ]
}
