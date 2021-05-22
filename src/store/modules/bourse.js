const state = {
  stocksProfile: null,
  stocksInfo: [],
  myStocksInfo: null
}

const getters = {
  stocksProfile: ({ stocksProfile }) => stocksProfile,
  stocksInfo: ({ stocksInfo }) => stocksInfo,
  myStocksInfo: ({ myStocksInfo }) => myStocksInfo
}

const actions = {
}

const mutations = {
  UPDATE_BOURSE_PROFILE (state, profile) {
    state.stocksProfile = profile
  },
  UPDATE_BOURSE_CRYPTO (state, crypto) {
    state.stocksInfo = crypto
  },
  UPDATE_BOURSE_PERSONAL_CRYPTO (state, crypto) {
    state.myStocksInfo = crypto
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

  state.myStocksInfo = [
    {
      totalPrice: 59699.074,
      totalBougth: 20,
      name: 'BTCN'
    }
  ]

  state.stocksInfo = [
    {
      currentMarket: 59699.074,
      closeMarket: 60056.664,
      name: 'BTCN'
    },
    {
      currentMarket: 2114.0967,
      closeMarket: 2113.3074,
      name: 'ETHR'
    },
    {
      currentMarket: 335.61954,
      closeMarket: 333.44257,
      name: 'BNBC'
    },
    {
      currentMarket: 0.057192378,
      closeMarket: 0.058815677,
      name: 'DOGE'
    },
    {
      currentMarket: 661.75,
      closeMarket: 667.93,
      name: 'COIL'
    },
    {
      currentMarket: 81.09,
      closeMarket: 78.5,
      name: 'LFI'
    },
    {
      currentMarket: 3161.0,
      closeMarket: 3094.08,
      name: 'GOP'
    },
    {
      currentMarket: 132.53,
      closeMarket: 132.89,
      name: 'SBURBN'
    },
    {
      currentMarket: 141.28,
      closeMarket: 141.45,
      name: 'ECOLA'
    },
    {
      currentMarket: 552.47,
      closeMarket: 533.93,
      name: 'DDEN'
    }
  ]

  // state.stocksInfo = []
}
