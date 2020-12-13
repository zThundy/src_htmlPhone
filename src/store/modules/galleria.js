// import PhoneAPI from './../../PhoneAPI'
// import CurrentTime from './CurrentTime'
// tutto questo codice è trovabile sulle impostazioni del telefono

const state = {
  fotografie: localStorage['gc_fotografie'] || []
}

const getters = {
  fotografie: ({ fotografie }) => fotografie
}

const actions = {
  addPhoto ({ commit, state }, data) {
    commit('APP_PHOTO', data)
    localStorage['gc_fotografie'] = state.fotografie
  },
  clearGallery ({ commit, state }) {
    commit('CLEAR_GALLERY')
    localStorage['gc_fotografie'] = []
  }
}

const mutations = {
  APP_PHOTO (state, data) {
    var foto = { link: data.link }
    // state.fotografie[state.fotografie.length] = { link: data.link, data: data.currentDate }
    state.fotografie.push(foto)
  },
  CLEAR_GALLERY (state) {
    state.fotografie = []
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
      link: 'https://i.imgur.com/rNXepFS.jpeg',
      data: 'bo forse'
    },
    {
      link: 'https://i.imgur.com/InUodqS.jpeg',
      data: 'bo forse'
    },
    {
      link: 'https://i.imgur.com/LQukntX.jpeg',
      data: 'bo forse'
    },
    {
      link: 'https://i.imgur.com/KIpi534.jpeg',
      data: 'bo forse'
    }
  ]
}
