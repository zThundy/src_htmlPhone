const state = {
  stocksProfile: null,
  stocksInfo: null
}

const getters = {
  stocksProfile: ({ stocksProfile }) => stocksProfile,
  stocksInfo: ({ stocksInfo }) => stocksInfo
}

const actions = {
  resetBourse ({ commit }) {
    commit('SET_BORSA_INFO', [])
  }
}

const mutations = {
  SET_BOURSE_INFO (state, stocksInfo) {
    state.stocksInfo = stocksInfo
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
  state.stocksProfile = {
    name: 'Gigino',
    surname: 'Pavone',
    balance: 5129382
  }

  state.stocksInfo = [
    {
      currentMarket: 59699.074,
      closeMarket: 60056.664,
      currency: 'USD',
      fakeName: 'BTCN',
      realName: 'BTC-USD'
    },
    {
      currentMarket: 2114.0967,
      closeMarket: 2113.3074,
      currency: 'USD',
      fakeName: 'ETHR',
      realName: 'ETH-USD'
    },
    {
      currentMarket: 335.61954,
      closeMarket: 333.44257,
      currency: 'USD',
      fakeName: 'BNBC',
      realName: 'BNB-USD'
    },
    {
      currentMarket: 0.057192378,
      closeMarket: 0.058815677,
      currency: 'USD',
      fakeName: 'DOGE',
      realName: 'DOGE-USD'
    },
    {
      currentMarket: 661.75,
      closeMarket: 667.93,
      currency: 'USD',
      fakeName: 'COIL',
      realName: 'TSLA'
    },
    {
      currentMarket: 81.09,
      closeMarket: 78.5,
      currency: 'USD',
      fakeName: 'LFI',
      realName: 'AMD'
    },
    {
      currentMarket: 3161.0,
      closeMarket: 3094.08,
      currency: 'USD',
      fakeName: 'GOP',
      realName: 'AMZN'
    },
    {
      currentMarket: 132.53,
      closeMarket: 132.89,
      currency: 'USD',
      fakeName: 'SBURBN',
      realName: 'NKE'
    },
    {
      currentMarket: 141.28,
      closeMarket: 141.45,
      currency: 'USD',
      fakeName: 'ECOLA',
      realName: 'PEP'
    },
    {
      currentMarket: 552.47,
      closeMarket: 533.93,
      currency: 'USD',
      fakeName: 'DDEN',
      realName: 'NVDA'
    }
  ]
}
