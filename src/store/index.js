import Vue from 'vue'
import Vuex from 'vuex'

import phone from './modules/phone'
import contacts from './modules/contacts'
import messages from './modules/messages'
import appels from './modules/appels'
import bank from './modules/bank'
import bourse from './modules/bourse'
import wifi from './modules/wifi'
import tchat from './modules/tchat'
import twitter from './modules/twitter'
import dati from './modules/dati'
import instagram from './modules/instagram'
import whatsapp from './modules/whatsapp'
import galleria from './modules/galleria'
import bluetooth from './modules/bluetooth'
import darkweb from './modules/darkweb'
import email from './modules/email'
import azienda from './modules/azienda'
// import videocalls from './modules/videocalls'
import yellows from './modules/yellowpages'

Vue.use(Vuex)

export default new Vuex.Store({
  modules: {
    phone,
    contacts,
    messages,
    appels,
    bank,
    bourse,
    tchat,
    twitter,
    dati,
    instagram,
    whatsapp,
    galleria,
    bluetooth,
    darkweb,
    email,
    azienda,
    wifi,
    // videocalls,
    yellows,
  },
  strict: true
})
