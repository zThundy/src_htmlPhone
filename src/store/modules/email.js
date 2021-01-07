import PhoneAPI from './../../PhoneAPI'
// import config from '../../../static/config/config'

const state = {
  myEmail: null,
  sentEmails: JSON.parse(window.localStorage['gc_sentemails'] || null),
  emails: JSON.parse(window.localStorage['gc_savedemails'] || null)
}

const getters = {
  emails: ({ emails }) => emails,
  sentEmails: ({ sentEmails }) => sentEmails,
  myEmail: ({ myEmail }) => myEmail
}

const actions = {
  deleteEmail ({ commit }, emailID) {
    commit('DELETE_EMAIL', emailID)
    PhoneAPI.deleteEmail(emailID)
  }
}

const mutations = {
  SETUP_EMAILS (state, emails) {
    window.localStorage['gc_savedemails'] = JSON.stringify(emails)
    state.emails = emails
  },
  SETUP_SENT_EMAILS (state, sentEmails) {
    window.localStorage['gc_sentemails'] = JSON.stringify(sentEmails)
    state.sentEmails = sentEmails
  },
  SETUP_MY_EMAIL (state, email) {
    state.myEmail = String(email)
  },
  DELETE_EMAIL (state, emailID) {
    state.emails = state.emails.filter((email, id) => { return id !== emailID })
    state.sentEmails = state.sentEmails.filter((email, id) => { return id !== emailID })
    // risalvo entrambi i localstorage PERCHE' SI
    window.localStorage['gc_savedemails'] = JSON.stringify(state.emails)
    window.localStorage['gc_sentemails'] = JSON.stringify(state.sentEmails)
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
  // state.myEmail = 'frank_trilly@code.it'
  state.emails = [
    {
      sender: 'frank_trilly@code.it',
      receiver: 'giovanni_lucky@code.it',
      title: 'dajdhbruendhsuridndndo24',
      message: 'Questo è il messaggio che stava nella email',
      time: time
    },
    {
      sender: 'giovanni_lucky@code.it',
      receiver: 'email_superlunga_franco@code.it',
      title: '2a email Questo è un titolo',
      message: 'Questo è il messaggio che stava nella email Questo è il messaggio che stava nella email Questo è il messaggio che stava nella email',
      time: time
    },
    {
      pic: 'https://u.trs.tn/tohqw.jpg',
      sender: 'giovanni_lucky@code.it',
      receiver: 'frank_trilly@code.it',
      title: '3a email Questo è un titolo',
      message: 'Questo è il messaggio che stava nella email Questo è il messaggio che stava nella email Questo è il messaggio che stava nella email',
      time: time
    },
    {
      sender: 'giovanni_lucky@code.it',
      receiver: 'frank_trilly@code.it',
      title: '4a email Questo è un titolo',
      message: 'Questo è il messaggio che stava nella email',
      time: time
    },
    {
      sender: 'giovanni_lucky@code.it',
      receiver: 'frank_trilly@code.it',
      title: '4a email Questo è un titolo',
      message: 'Questo è il messaggio che stava nella email',
      time: time
    },
    {
      sender: 'giovanni_lucky@code.it',
      receiver: 'frank_trilly@code.it',
      title: '4a email Questo è un titolo',
      message: 'Questo è il messaggio che stava nella email',
      time: time
    },
    {
      sender: 'giovanni_lucky@code.it',
      receiver: 'frank_trilly@code.it',
      title: '4a email Questo è un titolo',
      message: 'Questo è il messaggio che stava nella email',
      time: time
    },
    {
      sender: 'giovanni_lucky@code.it',
      receiver: 'frank_trilly@code.it',
      title: '4a email Questo è un titolo',
      message: 'Questo è il messaggio che stava nella email',
      time: time
    },
    {
      sender: 'giovanni_lucky@code.it',
      receiver: 'frank_trilly@code.it',
      title: '4a email Questo è un titolo',
      message: 'Questo è il messaggio che stava nella email',
      time: time
    },
    {
      sender: 'giovanni_lucky@code.it',
      receiver: 'frank_trilly@code.it',
      title: '4a email Questo è un titolo',
      message: 'Questo è il messaggio che stava nella email',
      time: time
    },
    {
      sender: 'giovanni_lucky@code.it',
      receiver: 'frank_trilly@code.it',
      title: '4a email Questo è un titolo',
      message: 'Questo è il messaggio che stava nella email',
      time: time
    }
  ]
  state.sentEmails = [
    {
      sender: 'frank_trilly@code.it',
      receiver: 'giovanni_lucky@code.it',
      title: 'email inviata',
      message: 'email inviata Questo è il messaggio che stava nella email',
      time: time
    },
    {
      sender: 'giovanni_lucky@code.it',
      receiver: 'email_superlunga_franco@code.it',
      title: 'email inviata ',
      message: 'email inviata Questo è il messaggio che stava nella email Questo è il messaggio che stava nella email Questo è il messaggio che stava nella email',
      time: time
    },
    {
      pic: 'https://u.trs.tn/tohqw.jpg',
      sender: 'giovanni_lucky@code.it',
      receiver: 'frank_trilly@code.it',
      title: 'email inviata ',
      message: 'email inviata Questo è il messaggio che stava nella email Questo è il messaggio che stava nella email Questo è il messaggio che stava nella email',
      time: time
    },
    {
      sender: 'giovanni_lucky@code.it',
      receiver: 'frank_trilly@code.it',
      title: '4a email Questo è un titolo',
      message: 'email inviata Questo è il messaggio che stava nella email',
      time: time
    },
    {
      sender: 'giovanni_lucky@code.it',
      receiver: 'frank_trilly@code.it',
      title: '4a email Questo è un titolo',
      message: 'email inviata Questo è il messaggio che stava nella email',
      time: time
    },
    {
      sender: 'giovanni_lucky@code.it',
      receiver: 'frank_trilly@code.it',
      title: '4a email Questo è un titolo',
      message: 'Questo è il messaggio che stava nella email',
      time: time
    },
    {
      sender: 'giovanni_lucky@code.it',
      receiver: 'frank_trilly@code.it',
      title: '4a email Questo è un titolo',
      message: 'Questo è il messaggio che stava nella email',
      time: time
    },
    {
      sender: 'giovanni_lucky@code.it',
      receiver: 'frank_trilly@code.it',
      title: '4a email Questo è un titolo',
      message: 'Questo è il messaggio che stava nella email',
      time: time
    },
    {
      sender: 'giovanni_lucky@code.it',
      receiver: 'frank_trilly@code.it',
      title: '4a email Questo è un titolo',
      message: 'Questo è il messaggio che stava nella email',
      time: time
    },
    {
      sender: 'giovanni_lucky@code.it',
      receiver: 'frank_trilly@code.it',
      title: '4a email Questo è un titolo',
      message: 'Questo è il messaggio che stava nella email',
      time: time
    },
    {
      sender: 'giovanni_lucky@code.it',
      receiver: 'frank_trilly@code.it',
      title: '4a email Questo è un titolo',
      message: 'Questo è il messaggio che stava nella email',
      time: time
    }
  ]
}
