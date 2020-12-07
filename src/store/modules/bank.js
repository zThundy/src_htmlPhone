import PhoneAPI from './../../PhoneAPI'

const state = {
  bankAmount: 0,
  iban: '#######'
}

const getters = {
  bankAmount: ({ bankAmount }) => bankAmount,
  iban: ({ iban }) => iban
}

const actions = {
  inviaSoldiAPI (_, { money, iban }) {
    PhoneAPI.postUpdateMoney(money, iban)
  }
}

const mutations = {
  SET_BANK_AMONT (state, bankAmount, iban) {
    state.bankAmount = Number(bankAmount)
    state.iban = iban
  }
}

export default {
  state,
  getters,
  actions,
  mutations
}

if (process.env.NODE_ENV !== 'production') {
  state.bankAmount = 2000
  state.iban = 'FJEN35K'
}

