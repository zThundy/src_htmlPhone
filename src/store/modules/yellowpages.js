const state = {
  yellows: []
}

const getters = {
  yellows: ({ yellows }) => yellows,
}

const actions = {
}

const mutations = {
}

export default { state, getters, actions, mutations }

if (process.env.NODE_ENV !== 'production') {
  state.yellows = [
    {
      description: "Questa è una descrizione molto bella e divertente",
      author: "5723729",
      identifier: "dev",
      number: "55538292",
      date: new Date()
    },
    {
      description: "2 Questa è una descrizione molto bella e divertente",
      author: "5655153",
      identifier: "dev",
      number: "55538291",
      date: new Date()
    },
    {
      description: "3 Questa è una descrizione molto bella e divertente questa è una descrizione molto bella e divertente questa è una descrizione molto bella e divertente",
      author: "4843215",
      identifier: "dev",
      number: "7845165",
      date: new Date()
    }
  ]
}
