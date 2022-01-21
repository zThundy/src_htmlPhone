const state = {
  yellows: []
}

const getters = {
  yellows: ({ yellows }) => yellows,
}

const actions = {
}

const mutations = {
  DELETE_YELLOW_POST(state, id) {
    state.yellows = state.yellows.filter((_, _id) => _id !== id)
  },
  RECEIVE_YELLOW_POSTS(state, data) {
    state.yellows = data
  }
}

export default { state, getters, actions, mutations }

if (process.env.NODE_ENV !== 'production') {
  state.yellows = [
    {
      description: "Questa è una descrizione molto bella e divertente",
      identifier: "1",
      number: "55538292",
      date: new Date()
    },
    {
      description: "2 Questa è una descrizione molto bella e divertente",
      identifier: "5655153",
      number: "55538291",
      date: new Date()
    },
    {
      description: "3 Questa è una descrizione molto bella e divertente questa è una descrizione molto bella e divertente questa è una descrizione molto bella e divertente",
      identifier: "4843215",
      number: "7845165",
      date: new Date()
    },
    {
      description: "3 Questa è una descrizione molto bella e divertente questa è una descrizione molto bella e divertente questa è una descrizione molto bella e divertente",
      identifier: "dev",
      number: "7845165",
      date: new Date()
    },
    {
      description: "3 Questa è una descrizione molto bella e divertente questa è una descrizione molto bella e divertente questa è una descrizione molto bella e divertente",
      identifier: "developer",
      number: "developer",
      date: new Date()
    }
  ]
}
