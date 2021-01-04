// import PhoneAPI from './../../PhoneAPI'
// import config from '../../../static/config/config'

const state = {
  myEmail: '',
  emails: JSON.parse(window.localStorage['gc_myemail'] || null)
}

const getters = {
  emails: ({ emails }) => emails,
  myEmail: ({ myEmail }) => myEmail
}

const actions = {
  setupEmails ({ commit }, emails) {
    commit('SETUP_APPSTORE_APPS', emails)
  }
}

const mutations = {
  SETUP_EMAILS (state, emails) {

  },
  SETUP_MY_EMAIL (state, email) {
    state.myEmail = email
  }
}

export default {
  state,
  getters,
  actions,
  mutations
}

if (process.env.NODE_ENV !== 'production') {
  const time = new Date().getTime()
  state.myEmail = 'frank_trilly@code.it'
  state.emails = [
    {
      sender: 'frank_trilly@code.it',
      receiver: 'giovanni_lucky@code.it',
      message: 'Questo è il messaggio che stava nella email',
      time: time
    },
    {
      sender: 'giovanni_lucky@code.it',
      receiver: 'frank_trilly@code.it',
      message: 'Questo è il messaggio che stava nella email Questo è il messaggio che stava nella email Questo è il messaggio che stava nella email',
      time: time
    }
  ]
}
