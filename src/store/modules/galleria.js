// import PhoneAPI from './../../PhoneAPI'
// import CurrentTime from './CurrentTime'
// tutto questo codice è trovabile sulle impostazioni del telefono

const state = {
  fotografie: window.localStorage['gc_fotografie'] || []
}

const getters = {
  fotografie: ({ fotografie }) => fotografie
}

const actions = {
  addPhoto ({ commit, state }, data) {
    commit('APP_PHOTO', data)
    window.localStorage['gc_fotografie'] = state.fotografie
  }
}

const mutations = {
  APP_PHOTO (state, data) {
    state.fotografie[state.fotografie.length] = {
      link: data.link
      // data: data.currentDate
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
  state.fotografie = [
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    },
    {
      link: 'https://u.trs.tn/tohqw.jpg',
      data: 'bo forse'
    }
  ]
}
