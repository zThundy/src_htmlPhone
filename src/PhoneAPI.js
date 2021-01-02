import store from '@/store'
import VoiceRTC from './VoiceRCT'
import Vue from 'vue'
import { Howl, Howler } from 'howler'

import emoji from './emoji.json'
const keyEmoji = Object.keys(emoji)

let USE_VOICE_RTC = false
const BASE_URL = 'http://zth_gcphone/'

/* eslint-disable camelcase */
class PhoneAPI {
  constructor () {
    // evento che controlla l'apertura e la chiusura del telefono:
    // aggiungere che ad event.data.show si apre il lockscreen
    window.addEventListener('message', (event) => {
      const eventType = event.data.event
      if (eventType !== undefined && typeof this['on' + eventType] === 'function') {
        this['on' + eventType](event.data)
      } else if (event.data.show !== undefined) {
        store.commit('SET_PHONE_VISIBILITY', event.data.show)
      }
    })
    this.config = null
    this.voiceRTC = null
    this.soundList = {}
    this.ttsplayers = {}
  }

  onsendParametersValues (data) {
    store.commit('SEND_INIT_VALUES', data)
  }

  // attenzione: per evitare l'Uncaught (in promise) error sulla console, è
  // necessario inserire il cb("ok") sul lua, visto che si aspetta qualcosa in ritorno
  async post (method, data) {
    try {
      const ndata = data === undefined ? '{}' : JSON.stringify(data)
      const response = await window.jQuery.post(BASE_URL + method, ndata)
      if (response === undefined || response === 'ok') return 'ok'
      return JSON.parse(response)
    } catch (e) { console.log(BASE_URL + method) }
  }

  async log (...data) {
    if (process.env.NODE_ENV === 'production') {
      return this.post('log', data)
    } else {
      return console.log(...data)
    }
  }

  async speakTTS (message, volume) {
    if ('speechSynthesis' in window) {
      var synthesis = window.speechSynthesis

      // Create an utterance object
      var utterance = new SpeechSynthesisUtterance(message)

      // Set utterance properties
      utterance.pitch = 0.0
      utterance.rate = 1.5
      // utterance.volume = volume - 0.1

      // Speak the utterance
      synthesis.speak(utterance)
    } else {
      console.log('Impossibile caricare il TTS')
    }
  }

  convertEmoji (text) {
    for (const e of keyEmoji) {
      text = text.replace(new RegExp(`:${e}:`, 'g'), emoji[e])
    }
    return text
  }

  // === Gestion des messages
  async sendMessage (phoneNumber, message) {
    return this.post('sendMessage', {phoneNumber, message})
  }

  async deleteMessage (id) {
    return this.post('deleteMessage', {id})
  }

  async deleteMessagesNumber (number) {
    return this.post('deleteMessageNumber', {number})
  }

  async deleteAllMessages () {
    return this.post('deleteAllMessage')
  }

  async setMessageRead (number) {
    return this.post('setReadMessageNumber', {number})
  }

  // === Gestion des contacts
  async updateContactAvatar (id, display, number, icon) {
    return this.post('aggiornaAvatarContatto', { id, display, number, icon })
  }

  async updateContact (id, display, phoneNumber) {
    return this.post('updateContact', { id, display, phoneNumber })
  }

  async addContact (display, phoneNumber) {
    return this.post('addContact', { display, phoneNumber })
  }

  async deleteContact (id) {
    return this.post('deleteContact', { id })
  }

  // == Gestion des appels
  async appelsDeleteHistorique (numero) {
    return this.post('appelsDeleteHistorique', { numero })
  }

  async appelsDeleteAllHistorique () {
    return this.post('appelsDeleteAllHistorique')
  }

  // === Autre
  async closePhone () {
    return this.post('closePhone')
  }

  async setGPS (x, y) {
    return this.post('setGPS', {x, y})
  }

  onaddPhotoToGallery (data) {
    store.dispatch('addPhoto', { link: data.link })
  }

  async savePictureObDb (data) {
    return this.post('savePicGalleryOnDb', data)
  }

  async takePhoto () {
    store.commit('SET_TEMPO_HIDE', true)
    const data = await this.post('takePhoto', { url: this.config.fileUploadService_Url, field: this.config.fileUploadService_Field })
    store.commit('SET_TEMPO_HIDE', false)
    if (data) {
      return data
    }
  }

  async sendErrorMessage (message) {
    return this.post('sendErrorMessage', { message: message })
  }

  async getReponseText (data) {
    // { text }
    if (process.env.NODE_ENV === 'production') {
      return this.post('reponseText', data || {})
    } else {
      return {text: window.prompt()}
    }
  }

  async faketakePhoto () {
    return this.post('faketakePhoto')
  }

  async callEvent (eventName, data) {
    return this.post('callEvent', {eventName, data})
  }

  async deleteALL () {
    localStorage.clear()
    store.dispatch('tchatReset')
    store.dispatch('resetPhone')
    store.dispatch('resetMessage')
    store.dispatch('resetContact')
    store.dispatch('resetBourse')
    store.dispatch('resetAppels')
    store.dispatch('resetDati')
    return this.post('deleteALL')
  }

  async getConfig () {
    if (this.config === null) {
      const response = await window.jQuery.get('/html/static/config/config.json')
      if (process.env.NODE_ENV === 'production') {
        this.config = JSON.parse(response)
      } else {
        this.config = response
      }
      if (this.config.useWebRTCVocal === true) {
        this.voiceRTC = new VoiceRTC(this.config.RTCConfig, this.config.RTCFilters)
        USE_VOICE_RTC = true
      }
      this.notififyUseRTC(this.config.useWebRTCVocal)
    }
    return this.config
  }

  async onsetEnableApp (data) {
    store.dispatch('setEnableApp', data)
  }

  async setIgnoreFocus (ignoreFocus) {
    this.post('setIgnoreFocus', { ignoreFocus })
  }

  // === App Tchat
  async tchatGetMessagesChannel (channel) {
    this.post('tchat_getChannel', { channel })
  }

  async tchatSendMessage (channel, message) {
    this.post('tchat_addMessage', { channel, message })
  }

  // === App Notes
  async notesGetMessagesChannel (channel) {
    window.localStorage.setItem('gc_notas_locales', channel)
  }

  async notesSendMessage (channel, message) {
    this.post('notes_addMessage', { channel, message })
  }

  // ==========================================================================
  //  Gestione degli eventi
  // ==========================================================================
  onupdateMyPhoneNumber (data) {
    store.commit('SET_MY_PHONE_NUMBER', data.myPhoneNumber)
  }

  onupdateMessages (data) {
    store.commit('SET_MESSAGES', data.messages)
  }

  onnewMessage (data) {
    store.commit('ADD_MESSAGE', data.message)
  }

  onupdateContacts (data) {
    store.commit('SET_CONTACTS', data.contacts)
  }

  onhistoriqueCall (data) {
    store.commit('SET_APPELS_HISTORIQUE', data.historique)
  }

  onupdateBankbalance (data) {
    store.commit('SET_BANK_AMONT', { money: data.soldi, iban: data.iban })
  }

  onupdateBankMovements (data) {
    store.commit('UPDATE_BANK_MOVEMENTS', data.movements)
  }

  async requestBankInfo () {
    return this.post('requestBankInfo')
  }

  async requestFatture () {
    return this.post('requestFatture')
  }

  async pagaFattura (fattura) {
    return this.post('pagaFattura', fattura)
  }

  async postUpdateMoney (money, iban) {
    return this.post('sendMoneyToIban', { money, iban })
  }

  onupdateBourse (data) {
    store.commit('SET_BOURSE_INFO', data.bourse)
  }

  // Call
  async startCall (numero, extraData = undefined) {
    if (USE_VOICE_RTC === true) {
      const rtcOffer = await this.voiceRTC.prepareCall()
      return this.post('startCall', { numero, rtcOffer, extraData })
    } else {
      return this.post('startCall', { numero, extraData })
    }
  }

  async acceptCall (infoCall) {
    if (USE_VOICE_RTC === true) {
      const rtcAnswer = await this.voiceRTC.acceptCall(infoCall)
      return this.post('acceptCall', { infoCall, rtcAnswer })
    } else {
      return this.post('acceptCall', { infoCall })
    }
  }

  async rejectCall (infoCall) {
    return this.post('rejectCall', { infoCall })
  }

  async notififyUseRTC (use) {
    return this.post('notififyUseRTC', use)
  }

  async ignoraChiamata (infoCall) {
    return this.post('ignoreCall', infoCall)
  }

  onwaitingCall (data) {
    store.commit('SET_APPELS_INFO_IF_EMPTY', {
      ...data.infoCall,
      initiator: data.initiator
    })
  }

  onacceptCall (data) {
    if (USE_VOICE_RTC === true) {
      if (data.initiator === true) {
        this.voiceRTC.onReceiveAnswer(data.infoCall.rtcAnswer)
      }
      this.voiceRTC.addEventListener('onCandidate', (candidates) => {
        this.post('onCandidates', { id: data.infoCall.id, candidates })
      })
    }
    store.commit('SET_APPELS_INFO_IS_ACCEPTS', true)
  }

  oncandidatesAvailable (data) {
    this.voiceRTC.addIceCandidates(data.candidates)
  }

  onrejectCall (data) {
    if (this.voiceRTC !== null) {
      this.voiceRTC.close()
    }
    store.commit('SET_APPELS_INFO', null)
  }

  async updateVolume (data) {
    data.volume = Math.floor10(data.volume, -2)
    return this.post('updateVolume', data)
  }

  async endSuoneriaForOthers () {
    return this.post('endSuoneriaForOthers')
  }

  async startSuoneriaForOthers (sound) {
    return this.post('startSuoneriaForOthers', { sound: sound })
  }

  onplaySound (data) {
    // console.log(data.sound, data.volume)
    // qui mi roundo il volume con le funzioni custom
    // definite a fine file
    data.volume = Math.floor10(data.volume)
    var path = '/html/static/sound/' + data.sound
    if (data.sound === undefined || data.sound === null) return
    if (this.soundList[data.sound] !== undefined) {
      this.soundList[data.sound].volume = Number(data.volume)
    } else {
      this.soundList[data.sound] = new Howl({
        src: path,
        loop: true,
        onend: function () { delete this.soundList[data.sound] }
      })
      this.soundList[data.sound].play()
    }
  }

  onupdateGlobalVolume (data) {
    data.volume = Math.floor10(data.volume, -2)
    Howler.volume(data.volume)
  }

  onsetSoundVolume (data) {
    if (this.soundList[data.sound] !== undefined) {
      data.volume = Math.floor10(data.volume)
      this.soundList[data.sound].volume(data.volume)
    }
  }

  onstopSound (data) {
    if (this.soundList[data.sound] !== undefined) {
      this.soundList[data.sound].pause()
      delete this.soundList[data.sound]
    }
  }

  async sendStartupValues (data) {
    return this.post('sendStartupValues', data)
  }

  // Tchat Event
  ontchat_receive (data) {
    store.dispatch('tchatAddMessage', data)
  }

  ontchat_channel (data) {
    store.commit('TCHAT_SET_MESSAGES', data)
  }

  // Notes Event
  onnotes_receive (data) {
    store.dispatch('notesAddMessage', data)
  }

  onnotes_channel (data) {
    store.commit('NOTES_SET_MESSAGES', data)
  }

  // =====================
  onautoStartCall (data) {
    this.startCall(data.number, data.extraData)
  }

  onautoAcceptCall (data) {
    store.commit('SET_APPELS_INFO', data.infoCall)
    this.acceptCall(data.infoCall)
  }

  // ==========================================================================
  //  Zona eventi e funzioni Twitter
  // ==========================================================================
  twitter_login (username, password) {
    this.post('twitter_login', { username, password })
  }

  twitter_changePassword (username, password, newPassword) {
    this.post('twitter_changePassword', { username, password, newPassword })
  }

  twitter_createAccount (username, password, avatarUrl) {
    this.post('twitter_createAccount', { username, password, avatarUrl })
  }

  twitter_postTweet (username, password, message) {
    this.post('twitter_postTweet', { username, password, message })
  }

  twitter_toggleLikeTweet (username, password, tweetId) {
    this.post('twitter_toggleLikeTweet', { username, password, tweetId })
  }

  twitter_setAvatar (username, password, avatarUrl) {
    this.post('twitter_setAvatarUrl', { username, password, avatarUrl })
  }

  twitter_getTweets (username, password) {
    this.post('twitter_getTweets', { username, password })
  }

  twitter_getFavoriteTweets (username, password) {
    this.post('twitter_getFavoriteTweets', { username, password })
  }

  ontwitter_tweets (data) {
    store.commit('SET_TWEETS', data)
  }

  ontwitter_favoritetweets (data) {
    store.commit('SET_FAVORITE_TWEETS', data)
  }

  ontwitter_newTweet (data) {
    store.dispatch('addTweet', data.tweet)
  }

  ontwitter_setAccount (data) {
    store.dispatch('setAccount', data)
  }

  ontwitter_updateTweetLikes (data) {
    store.commit('UPDATE_TWEET_LIKE', data)
  }

  ontwitter_setTweetLikes (data) {
    store.commit('UPDATE_TWEET_ISLIKE', data)
  }

  ontwitter_showError (data) {
    Vue.notify({
      title: store.getters.IntlString(data.title),
      message: store.getters.IntlString(data.message),
      icon: 'twitter',
      backgroundColor: '#e0245e80'
    })
  }

  ontwitter_showSuccess (data) {
    Vue.notify({
      title: store.getters.IntlString(data.title),
      message: store.getters.IntlString(data.message),
      icon: 'twitter'
    })
  }

  // ==========================================================================
  //  Zona eventi e funzioni Chiamate di emergenza
  // ==========================================================================

  async sendEmergencyMessage (data) {
    return this.post('chiamataEmergenza', data)
  }

  // ==========================================================================
  //  Zona eventi e funzioni Wifi e dati
  // ==========================================================================
  async requestOfferta () {
    return this.post('requestOfferta')
  }

  async connettiAllaRete (table) {
    return this.post('connettiAllaRete', table)
  }

  onupdateRetiWifi ({ data }) {
    store.commit('UPDATE_RETI_WIFI', data)
  }

  // questo ascolto è utile per capire, all'apertura del telefono
  // se sei connsesso al wifi o no
  // @data.hasWifi = false | true
  onupdateHasWifi ({ data }) {
    store.commit('UPDATE_HAS_WIFI', data.hasWifi)
  }

  onupdateOfferta ({ data }) {
    store.commit('UPDATE_OFFERTA', data)
  }

  // dati ricevuti dal nuimessage:
  // 0, 1, 2, 3, 4 per potenza segnale
  onupdateSegnale ({ data }) {
    var segnale = data.potenza
    store.commit('SET_SEGNALE', segnale)
  }
  // data contiene
  // {
  //   current: 299,
  //   max: 103,
  //   icon: 'phone'
  // }
  //
  // valori necessari!!
  // [1] MIN
  // [2] SMS
  // [3] MB
  onupdateDati ({ data }) {
    store.commit('SET_DATI_INFO', data)
  }

  // a questo messaggio va mandato
  // data.hasWifi come booleano
  onupdateWifi ({ data }) {
    store.dispatch('updateWifiString', data.hasWifi)
  }

  // == Schermata di sblocco
  async postPlayUnlockSound () {
    return this.post('soundLockscreen')
  }

  // ==========================================================================
  //  Zona eventi e funzioni Instagram
  // ==========================================================================
  async instagram_setAvatar (username, password, avatarUrl) {
    return this.post('instagram_changeAvatar', { username, password, avatarUrl })
  }
  // questo è la funzione generale
  // che ti permette di postare una nuova immagine
  // su instagram
  async instagram_postImage (username, password, imgTable) {
    return this.post('nuovoPost', { username, password, imgTable })
  }

  // funzione asincrona con post per controllo
  // username e password inseriti
  async instagram_login (username, password) {
    return this.post('loginInstagram', { username, password })
  }

  // questa funzione fa richiesta al database per prendere
  // tutti i post dal database per poi rimandarglieli al db
  async instagram_getPosts (username, password) {
    return this.post('requestPosts', { username, password })
  }

  // funzione asincrona per la creazione dell'account di instagram
  async instagram_createAccount (username, password, avatarUrl) {
    return this.post('createNewAccount', { username, password, avatarUrl })
  }

  // funzione del cambio password
  async instagram_changePassword (username, password, newPassword) {
    return this.post('changePassword', { username, password, newPassword })
  }

  async instagram_toggleLikePost (username, password, postId) {
    Vue.notify({
      sound: 'Instagram_Like_Sound.ogg',
      backgroundColor: 'rgba(0, 0, 0, 0)'
    })
    return this.post('togglePostLike', { username, password, postId })
  }

  // questo evento riceve dal client del lua
  // la table del post fatta dall'utente, già buildata
  // come il database
  oninstagramNewPost (data) {
    store.dispatch('instagramNewPostFinale', data.post)
  }

  oninstagramRecivePosts (posts) {
    store.commit('SET_POSTS', posts)
  }

  oninstagram_setAccount ({ data }) {
    store.dispatch('setInstagramAccount', data)
  }

  oninstagramSetupAccount ({ data }) {
    store.dispatch('setInstagramAccount', data)
  }

  // questo messaggio dal lua aggiorna i tutti i like del
  // post per tutti i giocatori al trigger
  // data.postId, data.likes
  oninstagram_updatePostLikes (data) {
    store.commit('UPDATE_POST_LIKES', data)
  }

  // questo messaggio dal lua aggiorna il like del player singolo
  // facendolo eventualmente diventare rosso
  // data.postId, data.isLike
  oninstagram_updatePostIsLiked (data) {
    store.commit('UPDATE_POST_ISLIKE', data)
  }

  // notifica di errore
  oninstagram_showError (data) {
    Vue.notify({
      title: store.getters.IntlString(data.title),
      message: store.getters.IntlString(data.message),
      icon: 'instagram',
      backgroundColor: '#66000080',
      sound: 'Instagram_Error.ogg'
    })
  }

  // notifica di successo
  oninstagram_showSuccess (data) {
    Vue.notify({
      title: store.getters.IntlString(data.title),
      message: store.getters.IntlString(data.message),
      icon: 'instagram',
      backgroundColor: '#FF66FF80',
      sound: 'Instagram_Notification.ogg'
    })
  }

  // ///////////////////////// //
  // SEZIONE WHATSAPP TELEFONO //
  // ///////////////////////// //

  // notifica di errore
  onwhatsapp_showError (data) {
    Vue.notify({
      title: store.getters.IntlString(data.title),
      message: store.getters.IntlString(data.message),
      icon: 'whatsapp',
      backgroundColor: '#00996680',
      sound: 'Whatsapp_Error.ogg'
    })
  }

  // notifica di successo
  onwhatsapp_showSuccess (data) {
    Vue.notify({
      title: store.getters.IntlString(data.title),
      message: store.getters.IntlString(data.message),
      icon: 'whatsapp',
      backgroundColor: '#33CC6680',
      sound: 'Whatsapp_Notification.ogg'
    })
  }

  onwhatsappClearGroups () {
    store.commit('CLEAR_GROUP')
  }

  onwhatsappReceiveGroups (data) {
    store.commit('UPDATE_GROUP', data.group)
  }

  onwhatsappGetReturnedGroups (data) {
    store.commit('UPDATE_POST_ISLIKE', data)
  }

  onwhatsappShowMessageNotification (data) {
    store.dispatch('showMessageNotification', data.info)
  }

  onwhatsappReceiveMessages (data) {
    store.commit('UPDATE_MESSAGGI', data.messages)
  }

  async abbandonaGruppo (gruppo) {
    return this.post('abbandonaGruppo', { gruppo })
  }

  async requestWhatsappMessaggi (groupId) {
    return this.post('requestWhatsappeMessages', { id: groupId })
  }

  async sendMessageOnGroup (messaggio, id, phoneNumber) {
    return this.post('sendMessageInGroup', { messaggio, id, phoneNumber })
  }

  async sendAudioNotification () {
    return this.post('sendAudioNotification')
  }

  async requestInfoOfGroups () {
    return this.post('requestAllGroupsInfo')
  }

  async postCreazioneGruppo (data) {
    return this.post('inviaValoriPost', data)
  }

  async updateNotifications (data) {
    return this.post('updateNotifications', data)
  }

  async updateAirplane (data) {
    return this.post('updateAirplane', data)
  }

  async updateGroupInfo (data) {
    return this.post('updateGroup', data)
  }

  async addGroupMembers (data) {
    return this.post('addGroupMembers', data)
  }

  // ////////////////////// //
  // SEZIONE COVER TELEFONO //
  // ////////////////////// //

  async requestMyCovers () {
    return this.post('requestMyCovers')
  }

  async changingCover (cover) {
    return this.post('changingCover', { cover: cover })
  }

  onchangePhoneCover (data) {
    // console.log(data.label, data.cover)
    store.commit('SET_CURRENT_COVER', { label: data.label, value: data.cover })
  }

  onreceiveCovers (data) {
    store.commit('UPDATE_MY_COVERS', data.covers)
  }

  // ////////////////////////// //
  // SEZIONE BLUETOOTH TELEFONO //
  // ////////////////////////// //

  async requestClosestPlayers (bool) {
    return this.post('requestBluetoothPlayers', { toggle: bool })
  }

  async sendPicToUser (data) {
    this.post('sendPicToUser', data)
  }

  onsendClosestPlayers (users) {
    store.commit('UPDATE_CLOSEST_PLAYERS', users)
  }

  onaddPicToGallery (data) {
    store.dispatch('addPhoto', data)
  }

  onclearGallery () {
    store.dispatch('clearGallery')
  }

  // //////////////// //
  // DARKWEB FUNZIONI //
  // //////////////// //

  async fetchDarkmessages () {
    return this.post('fetchDarkmessages')
  }

  async sendDarkMessage (message) {
    return this.post('sendDarkMessage', { message: message })
  }

  onsendDarkwebMessages (data) {
    store.commit('RECEIVE_DARK_MESSAGES', data)
  }
}

function decimalAdjust (type, value, exp) {
  // If the exp is undefined or zero...
  if (typeof exp === 'undefined' || +exp === 0) {
    return Math[type](value)
  }
  value = +value
  exp = +exp
  // If the value is not a number or the exp is not an integer...
  if (isNaN(value) || !(typeof exp === 'number' && exp % 1 === 0)) {
    return NaN
  }
  // Shift
  value = value.toString().split('e')
  value = Math[type](+(value[0] + 'e' + (value[1] ? (+value[1] - exp) : -exp)))
  // Shift back
  value = value.toString().split('e')
  return +(value[0] + 'e' + (value[1] ? (+value[1] + exp) : exp))
}

// Decimal ceil
if (!Math.ceil10) {
  Math.ceil10 = function (value, exp) {
    return decimalAdjust('ceil', value, exp)
  }
}
// Decimal floor
if (!Math.floor10) {
  Math.floor10 = function (value, exp) {
    return decimalAdjust('floor', value, exp)
  }
}

const instance = new PhoneAPI()

export default instance
