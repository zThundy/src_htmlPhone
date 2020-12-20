import PhoneAPI from './../../PhoneAPI'

const state = {
  bankAmount: 0,
  iban: '#######',
  fatture: [],
  movements: []
}

const getters = {
  bankAmount: ({ bankAmount }) => bankAmount,
  iban: ({ iban }) => iban,
  fatture: ({ fatture }) => fatture,
  movements: ({ movements }) => movements
}

const actions = {
  // funzione outdated banca
  // inviaSoldiAPI (_, { money, iban }) {
  //   PhoneAPI.postUpdateMoney(money, iban)
  // },
  async createPagamento ({ commit }) {
    var iban = await PhoneAPI.getReponseText({ limit: 200, text: 'Inserisci l\'iban del destinatario' })
    var amount = await PhoneAPI.getReponseText({ limit: 200, text: 'Inserisci l\'ammontare del trasferimento' })
    PhoneAPI.postUpdateMoney(Number(amount.text), iban.text.toUpperCase())
    // commit('ADD_MOVEMENT', { money: Number(amount.text), iban: iban.text.toUpperCase() })
  },
  async requestFatture ({ commit }) {
    var fatture = await PhoneAPI.requestFatture()
    commit('UPDATE_FATTURE', fatture)
  }
}

const mutations = {
  SET_BANK_AMONT (state, bankAmount, iban) {
    state.bankAmount = Number(bankAmount)
    state.iban = iban
  },
  UPDATE_FATTURE (state, fatture) {
    state.fatture = fatture
  },
  UPDATE_BANK_MOVEMENTS (state, movements) {
    state.movements = movements
  },
  ADD_MOVEMENT (state, data) {
    state.movements.push({
      id: state.movements.length + 1,
      amount: data.money,
      type: 'negative',
      to: data.iban,
      from: state.iban
    })
  }
}

export default {
  state,
  getters,
  actions,
  mutations
}

if (process.env.NODE_ENV !== 'production') {
  state.bankAmount = 2000000
  state.iban = 'FJEN35K'
  state.fatture = [
    {
      id: 1,
      identifier: 1,
      sender: 2,
      target_type: 'society',
      target: 'society_ambulance',
      label: 'Ospedale',
      amount: 2000
    },
    {
      id: 500,
      identifier: 1,
      sender: 2,
      target_type: 'society',
      target: 'society_ambulance',
      label: 'Ospedale',
      amount: 5000
    }
  ]
  state.movements = [
    {
      id: 1,
      amount: '2000',
      type: 'positive',
      to: 'NFJD39A',
      from: 'FJEN35K'
    }
  ]
}

