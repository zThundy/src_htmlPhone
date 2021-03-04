// import PhoneAPI from './../../PhoneAPI'

const state = {
  myJobInfo: null,
  myAziendaInfo: null,
  buttons: [
    {
      id: 'employes',
      label: 'APP_AZIENDA_EMPLYES_LIST'
    },
    {
      id: 'salary',
      label: 'APP_AZIENDA_MANAGE_SALARY'
    },
    {
      id: 'chat',
      label: 'APP_AZIENDA_EMPLOYES_CHAT'
    }
  ],
  aziendaMessages: null,
  aziendaIngoreControls: false
}

const getters = {
  myJobInfo: ({ myJobInfo }) => myJobInfo,
  myAziendaInfo: ({ myAziendaInfo }) => myAziendaInfo,
  buttons: ({ buttons }) => buttons,
  aziendaMessages: ({ aziendaMessages }) => aziendaMessages,
  aziendaIngoreControls: ({ aziendaIngoreControls }) => aziendaIngoreControls
}

const actions = {
}

const mutations = {
  SET_AZIENDA_IGNORE_CONTROLS (state, bool) {
    state.aziendaIngoreControls = bool
  },
  UPDATE_AZIENDA_APP (state, data) {
    state.myJobInfo = data.myJobInfo
    state.myAziendaInfo = data.myAziendaInfo
  },
  UPDATE_AZIENDA_MESSAGES (state, messages) {
    state.aziendaMessages = messages
  },
  UPDATE_AZIENDA_EMPLOYES (state, employes) {
    state.myAziendaInfo.employes = employes
  }
}

export default {
  state,
  getters,
  actions,
  mutations
}

if (process.env.NODE_ENV !== 'production') {
  // name = "Tizio caio",
  // gradeName = "Capo",
  // salary = 0,
  // grade = 3,
  // jobName = "mechanic",
  // jobLabel = "Meccanico",
  // canedit = true -- permette di modificare le cose da capo

  state.myJobInfo = {
    name: 'Juba ja',
    gradeName: 'Direttore',
    grade: 3,
    buttons: {
      'employes': true,
      'salary': true,
      'chat': true
    }
  }

  state.myAziendaInfo = {
    money: 200000000,
    label: 'Supercalifragilisichespirali',
    name: 'police',
    // img: 'https://g.foolcdn.com/editorial/images/578933/square01.jpg',
    employes: [
      {
        steamid: 1283,
        grade: 0,
        gradeName: 'Dipendente',
        name: 'Frank Trullal',
        phoneNumber: 5557392,
        salary: 0,
        isOnline: false
      },
      {
        steamid: 1637,
        grade: 1,
        gradeName: 'Operaio',
        name: 'Johhni ok',
        phoneNumber: 5552982,
        salary: 0,
        isOnline: true
      },
      {
        steamid: 1938,
        grade: 3,
        gradeName: 'Direttore',
        name: 'Profex gay',
        phoneNumber: 55501367,
        salary: 0,
        isOnline: true
      },
      {
        steamid: 1938,
        grade: 3,
        gradeName: 'Direttore',
        name: 'Profex gay',
        phoneNumber: 55501367,
        salary: 0,
        isOnline: true
      },
      {
        steamid: 1938,
        grade: 3,
        gradeName: 'Direttore',
        name: 'Profex gay',
        phoneNumber: 55501367,
        salary: 0,
        isOnline: true
      },
      {
        steamid: 1283,
        grade: 0,
        gradeName: 'Dipendente',
        name: 'Frank Trullal',
        phoneNumber: 5557392,
        salary: 0,
        isOnline: false
      },
      {
        steamid: 1283,
        grade: 0,
        gradeName: 'Dipendente',
        name: 'Frank Trullal',
        phoneNumber: 5557392,
        salary: 0,
        isOnline: false
      },
      {
        steamid: 1283,
        grade: 0,
        gradeName: 'Dipendente',
        name: 'Frank Trullal',
        phoneNumber: 5557392,
        salary: 0,
        isOnline: false
      }
    ]
  }

  state.aziendaMessages = [
    {
      message: 'test message 12345 test message 12345 test message 12345 test message 12345',
      author: 'Jumba ja',
      authorPhone: 55538823,
      mine: true
    },
    {
      message: 'test message 12345',
      author: 'Frank trull',
      authorPhone: 55538823,
      mine: false
    },
    {
      message: 'test message 12345 test message 12345 test message 12345 test message 12345',
      author: 'Jumba ja',
      authorPhone: 55538823,
      mine: true
    },
    {
      message: 'test message 12345',
      author: 'Frank trull',
      authorPhone: 55538823,
      mine: false
    },
    {
      message: 'test message 12345 test message 12345 test message 12345 test message 12345',
      author: 'Jumba ja',
      authorPhone: 55538823,
      mine: true
    },
    {
      message: 'test message 12345',
      author: 'Frank trull',
      authorPhone: 55538823,
      mine: false
    },
    {
      message: 'test message 12345 test message 12345 test message 12345 test message 12345',
      author: 'Jumba ja',
      authorPhone: 55538823,
      mine: true
    },
    {
      message: 'test message 12345',
      author: 'Frank trull',
      authorPhone: 55538823,
      mine: false
    },
    {
      message: 'GPS: -1034.5810546875, -2734.1027832031',
      author: 'Jumba ja',
      authorPhone: 55538823,
      mine: true
    },
    {
      message: 'GPS: -1034.5810546875, -2734.1027832031',
      author: 'Frank trull',
      authorPhone: 55538823,
      mine: false
    },
    {
      message: 'test message 12345',
      author: 'Frank trull',
      authorPhone: 55538823,
      mine: false
    }
  ]
}
