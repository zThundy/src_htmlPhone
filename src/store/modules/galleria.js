// import PhoneAPI from './../../PhoneAPI'
// import CurrentTime from './CurrentTime'
// tutto questo codice è trovabile sulle impostazioni del telefono

const state = {
  fotografie: JSON.parse(window.localStorage['gc_fotografie'] || null) || []
}

const getters = {
  fotografie: ({ fotografie }) => fotografie
}

const actions = {
  addPhoto ({ commit, state }, data) {
    // console.log('received addPhoto data')
    // console.log(JSON.stringify(data))
    commit('APP_PHOTO', data)
    window.localStorage['gc_fotografie'] = JSON.stringify(state.fotografie)
    // console.log(JSON.stringify(window.localStorage['gc_fotografie']))
  },
  clearGallery ({ commit, state }) {
    commit('CLEAR_GALLERY')
    window.localStorage['gc_fotografie'] = []
  },
  deleteSinglePicture ({ commit, state }, index) {
    commit('DELETE_PICTURE', index)
  }
}

const mutations = {
  APP_PHOTO (state, data) {
    state.fotografie.push(data)
  },
  CLEAR_GALLERY (state) {
    state.fotografie = []
  },
  DELETE_PICTURE (state, index) {
    state.fotografie.splice(index - 1, 1)
    window.localStorage['gc_fotografie'] = JSON.stringify(state.fotografie)
  }
}

export default { state, getters, actions, mutations }

if (process.env.NODE_ENV !== 'production') {
  state.fotografie = [
    {
      link: 'https://cdn.discordapp.com/attachments/848629680655433738/932002729499426846/zth_gcphone.picture.png',
      type: 'photo'
    },
    {
      link: 'https://i.imgur.com/rNXepFS.jpeg',
      type: 'photo'
    },
    {
      link: 'https://i.imgur.com/InUodqS.jpeg',
      type: 'photo'
    },
    {
      link: 'https://i.imgur.com/LQukntX.jpeg',
      type: 'photo'
    },
    {
      link: 'https://i.imgur.com/KIpi534.jpeg',
      type: 'photo'
    },
    {
      link: '[VIDEO]%646467%8deQpNthxKbWA7m7S0OK',
      type: 'video'
    }
  ]
}
