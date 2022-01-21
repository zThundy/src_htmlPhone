import store from '@/store'
import Vue from 'vue'

// import of custom classes
import VoiceRTC from './VoiceRTC'
import PictureRequest from './PictureRequest'
import VideoRequest from './VideoRequest'

const BASE_URL = 'http://zth_gcphone/'

/* eslint-disable camelcase */
class PhoneAPI {
  constructor () {
    console.log('[MODULE] PhoneAPI initialized')
    // evento che controlla tutti i messaggi che vengono mandati dal lua
    // per poi chiamare le funzioni che iniziano con "on"
    window.addEventListener('message', (event) => {
      if (event.data.event !== undefined && typeof this['on' + event.data.event] === 'function') {
        this['on' + event.data.event](event.data)
      } else if (event.data.show !== undefined) {
        store.commit('SET_PHONE_VISIBILITY', event.data.show)
      } else if (event.data.halfShow !== undefined) {
        store.commit('SET_HALF_SHOW', event.data.halfShow)
      }
    })

    fetch('/html/static/config/config.json', { method: 'GET', mode: 'cors' })
    .then(response => response.text())
    .then(rawConfig => {
      this.config = JSON.parse(rawConfig)
      this.voiceRTC = null
      this.soundList = []
      this.audioElement = new Audio()
      this.keyAudioElement = new Audio()
      // initialize the videorequest class every time the phone
      // is actually initialized
      this.videoRequest = new VideoRequest(this.config.fileUploader.ip, this.config.fileUploader.port)
      // initialize the picturerequest class every time the phone
      // is actually initialized
      this.picture = new PictureRequest(this.config.picturesConfig)
      if (this.config.enableWebRTC) this.voiceRTC = new VoiceRTC(this.config.RTCConfig, this.config.RTCFilters)
      this.post('notififyUseRTC', this.voiceRTC)
      store.dispatch('loadConfig', this.config)
    })

    fetch('/html/static/config/emoji.json', { method: 'GET', mode: 'cors' })
    .then(response => response.text())
    .then(rawEmoji => {
      this.emoji = JSON.parse(rawEmoji)
    })
  }

  // attenzione: per evitare l'Uncaught (in promise) error sulla console, è
  // necessario inserire il cb("ok") sul lua, visto che si aspetta qualcosa in ritorno
  async post (method, data) {
    try {
      const ndata = data === undefined ? '{}' : JSON.stringify(data)
      const response = await fetch(BASE_URL + method, {
        method: 'POST',
        mode: 'cors',
        body: ndata
      })
      .then(response => response.text())
      .then(text => { return JSON.parse(text) })
      if (response === 'ok' || !response) return 'ok'
      return JSON.parse(response)
    } catch (e) { console.log(BASE_URL + method) }
  }

  async sendLicenseResponse (bool) {
    return this.post('PhoneNeedAuth', bool)
  }

  onphoneChecks (data) {
    store.commit('SET_LOADED_VALUE', data)
  }

  getEmojis () {
    return this.emoji
  }

  convertEmoji (text) {
    if (text) for (const e in this.emoji) text = text.replace(new RegExp(`:${e}:`, 'g'), this.emoji[e])
    return text
  }

  async takePhoto (openCamera = true) {
    return new Promise(async (resolve, reject) => {
      let tmp_status = true
      if (openCamera) tmp_status = await this.openFakeCamera()
      if (tmp_status) {
        const pic = await this.picture.getPicture()
        if (pic && pic !== '') {
          this.post('setEnabledFakeCamera', false)
          this.onaddPhotoToGallery({ link: pic })
          resolve(pic)
        } else {
          reject('cant-get-pic')
        }
      }
    })
  }

  onsendParametersValues (data) {
    store.commit('SEND_INIT_VALUES', data)
  }

  async deleteMessagesNumber (number) {
    return this.post('deleteMessageNumber', { number })
  }

  async deleteAllMessages () {
    return this.post('deleteAllMessage')
  }

  async setMessageRead (number) {
    return this.post('setReadMessageNumber', { number })
  }

  async updateContactAvatar (id, display, number, icon) {
    return this.post('updateContactAvatar', { id, display, number, icon })
  }

  async updateContact (id, display, phoneNumber, email, icon) {
    return this.post('updateContact', { id, display, phoneNumber, email, icon })
  }

  async addContact (display, phoneNumber, email, icon) {
    return this.post('addContact', { display, phoneNumber, email, icon })
  }

  async deleteContact (id) {
    return this.post('deleteContact', { id })
  }

  async shareContact (contact) {
    return this.post('shareContact', contact)
  }

  async deletePhoneHistory (numero) {
    return this.post('deletePhoneHistory', { numero })
  }

  async deleteAllPhoneHistory () {
    return this.post('deleteAllPhoneHistory')
  }

  async closePhone () {
    return this.post('closePhone')
  }

  async setGPS (x, y) {
    return this.post('setGPS', { x, y })
  }

  onaddPhotoToGallery (data) {
    if (data) store.dispatch('addPhoto', { link: data.link, type: 'photo' })
  }

  async openFakeCamera (ignoreControls = false) {
    return this.post('openFakeCamera', { ignoreControls })
  }

  async sendErrorMessage (message) {
    return this.post('sendErrorMessage', { message: message })
  }

  async setNUIFocus (bool) {
    return this.post('setNuiFocus', bool)
  }

  async getReponseText (data) {
    if (process.env.NODE_ENV === 'production') {
      return this.post('responseText', data || {})
    } else {
      return { text: window.prompt() }
    }
  }

  async callEvent (eventName, data) {
    return this.post('callEvent', { eventName, data })
  }

  async deleteALL () {
    localStorage.clear()
    store.dispatch('tchatReset')
    store.dispatch('resetPhone')
    store.dispatch('resetMessage')
    store.dispatch('resetContact')
    store.dispatch('resetAppels')
    store.dispatch('resetDati')
    return this.post('deleteALL')
  }

  async tchatGetMessagesChannel (channel) {
    this.post('tchat_getChannel', { channel })
  }

  async tchatSendMessage (channel, message) {
    this.post('tchat_addMessage', { channel, message })
  }

  onupdateMyPhoneNumber (data) {
    store.commit('SET_MY_PHONE_NUMBER', data.myPhoneNumber)
  }

  onupdateMessages (data) {
    if (Number(data.received) > 0) { Vue.notify({ sound: 'msgnotify.ogg', hidden: true, volume: data.volume || 0.2 }) }
    store.commit('SET_MESSAGES', data.messages)
  }

  onnewMessage (data) {
    store.commit('ADD_MESSAGE', data.message)
  }

  ongenericNotification (data) {
    if (data.notify) data = data.notif
    if (data.notif) data = data.notif
    Vue.notify({
      message: store.getters.LangString(data.message),
      title: store.getters.LangString(data.title) + ':',
      icon: data.icon,
      backgroundColor: data.color,
      appName: data.appName,
      sound: data.sound
    })
  }

  onupdateContacts (data) {
    store.commit('SET_CONTACTS', data.contacts)
  }

  onhistoryCalls (data) {
    store.commit('SET_APPELS_HISTORIQUE', data.history)
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

  onreceivePlayerFatture (data) {
    store.commit('UPDATE_FATTURE', data.fatture)
  }

  async pagaFattura (fattura) {
    return this.post('pagaFattura', fattura)
  }

  async postUpdateMoney (money, iban) {
    return this.post('sendMoneyToIban', { money, iban })
  }

  async startVideoCall({ number, stream }, extraData = undefined) {
    if (this.voiceRTC) {
      const offer = await this.voiceRTC.prepareCall(stream)
      console.log(offer)
      return this.post("startVideoCall", { numero: number, offer, extraData })
    }
  }

  async startCall ({ numero }, extraData = undefined) {
    if (this.voiceRTC) {
      const rtcOffer = await this.voiceRTC.prepareCall()
      return this.post('startCall', { numero, rtcOffer, extraData })
    } else {
      return this.post('startCall', { numero, extraData })
    }
  }

  async acceptCall (infoCall) {
    if (this.voiceRTC) {
      const rtcAnswer = await this.voiceRTC.acceptCall(infoCall)
      return this.post('acceptCall', { infoCall, rtcAnswer })
    } else {
      return this.post('acceptCall', { infoCall })
    }
  }

  removeElementAtIndex (array, index) {
    var tempArray = []
    array.forEach((elem) => {
      if (array.indexOf(elem) !== index) tempArray.push(elem)
    })
    return tempArray
  }

  makeid (length, addTime) {
    var result = ''
    var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    var charactersLength = characters.length
    for (var i = 0; i < length; i++) result += characters.charAt(Math.floor(Math.random() * charactersLength))
    if (addTime) {
      const date = new Date()
      result = date.getTime() + result
    }
    return result
  }

  isLink (message) {
    var pattern = new RegExp('^(https?:\\/\\/)?' + '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|' + '((\\d{1,3}\\.){3}\\d{1,3}))' + '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*' + '(\\?[;&a-z\\d%_.~+=-]*)?' + '(\\#[-a-z\\d_]*)?$', 'i')
    return !!pattern.test(message)
  }

  async rejectCall (infoCall) {
    this.post('rejectCall', { infoCall })
  }

  async ignoreCall (infoCall) {
    return this.post('ignoreCall', { infoCall })
  }

  oninitVoiceMail (data) {
    Vue.prototype.$bus.$emit('initVoiceMail', data.infoCall)
    store.commit('SET_APPELS_INFO_IS_ACCEPTS', true)
    this.post('acceptCall', data)
  }

  onnoSignal (data) {
    setTimeout(() => {
      this.audioElement.src = '/html/static/sound/phonenosignal.ogg'
      this.audioElement.volume = 0.2
      this.audioElement.onended = () => {
        this.post('rejectCall', data)
      }
      this.audioElement.play()
    }, 250)
  }

  onwaitingCall (data) {
    store.commit('SET_APPELS_INFO_IF_EMPTY', { ...data.infoCall, initiator: data.initiator })
    if (data.infoCall.receiver_num === this.config.voicemails_number && data.infoCall.noSignal === undefined) {
      setTimeout(() => {
        Vue.prototype.$bus.$emit('initVoiceMailListener', data)
        store.commit('SET_APPELS_INFO_IS_ACCEPTS', true)
        this.post('acceptCall', data)
      }, 3000)
    }
  }

  onacceptCall (data) {
    if (this.voiceRTC) {
      if (data.initiator === true) this.voiceRTC.onReceiveAnswer(data.infoCall.rtcAnswer)
      this.voiceRTC.addEventListener('onCandidate', (candidates) => { this.post('onCandidates', { id: data.infoCall.id, candidates }) })
    }
    store.commit('SET_APPELS_INFO_IS_ACCEPTS', true)
  }

  oncandidatesAvailable (data) {
    this.voiceRTC.addIceCandidates(data.candidates)
  }

  async sendVoicemailMessage(data) {
    return this.post("newVoicemail", data)
  }

  onrejectCall (data) {
    Vue.prototype.$bus.$emit('stopVoiceMailRecording', { callDropped: data.infoCall.callDropped })
    if (this.voiceRTC !== null) { this.voiceRTC.close() }
    store.commit('SET_APPELS_INFO', null)
  }

  async updateVolume (data) {
    data.volume = decimalAdjust('floor', data.volume, -2)
    return this.post('updateVolume', data)
  }

  onplaySound (data) {
    // qui mi roundo il volume con le funzioni custom
    // definite a fine file
    data.volume = decimalAdjust('floor', data.volume, -2)
    var path = '/html/static/sound/' + data.sound
    if (data.sound === undefined || data.sound === null) return
    if (this.soundList[data.sound] !== undefined) {
      this.soundList[data.sound].volume = Number(data.volume)
    } else {
      this.soundList[data.sound] = new Audio()
      this.soundList[data.sound].src = path
      this.soundList[data.sound].loop = data.loop || false
      this.soundList[data.sound].play()
      this.soundList[data.sound].onended = () => {
        delete this.soundList[data.sound]
      }
    }
  }

  playKeySound (data) {
    if (data.file) {
      this.keyAudioElement.src = '/html/static/sound/phoneDialogsEffect/' + data.file + '.ogg'
      this.keyAudioElement.volume = 0.1
      this.keyAudioElement.play()
    }
  }

  onupdateGlobalVolume (data) {
    data.volume = decimalAdjust('floor', data.volume, -2)
    if (this.soundList) {
      this.soundList.forEach((elem, sound) => {
        if (!elem) return
        elem.volume = data.volume
      })
    }
  }

  onsetSoundVolume (data) {
    if (this.soundList[data.sound] !== undefined) {
      data.volume = decimalAdjust('floor', data.volume, -2)
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

  ontchat_receive (data) {
    store.commit('TCHAT_ADD_MESSAGES', data.message)
  }

  ontchat_channel (data) {
    store.commit('TCHAT_SET_MESSAGES', data.messages)
  }

  onnotes_receive (data) {
    store.dispatch('notesAddMessage', data)
  }

  onnotes_channel (data) {
    store.commit('NOTES_SET_MESSAGES', data)
  }

  onautoStartCall (data) {
    this.startCall({ numero: data.number }, data.extraData)
  }

  onautoAcceptCall (data) {
    store.commit('SET_APPELS_INFO', data.infoCall)
    this.acceptCall(data.infoCall)
  }

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
    store.dispatch('addTweet', { tweet: data.tweet, sourceAuthor: data.sourceAuthor })
  }

  ontwitter_setAccount (data) {
    if (!data.logged) data.logged = true
    store.dispatch('setAccount', data)
  }

  ontwitter_updateTweetLikes (data) {
    store.commit('UPDATE_TWEET_LIKE', data)
  }

  ontwitter_setTweetLikes (data) {
    store.commit('UPDATE_TWEET_ISLIKE', data)
  }

  async sendEmergencyMessage (data) {
    data.services = this.config.serviceCall
    return this.post('chiamataEmergenza', data)
  }

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
  onupdateSegnale (data) {
    store.commit('SET_SEGNALE', data.potenza)
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
    store.commit('UPDATE_WIFI', data)
  }

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
    Vue.notify({ sound: 'Instagram_Like_Sound.ogg', hidden: true, volume: 0.2 })
    return this.post('togglePostLike', { username, password, postId })
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

  onwhatsappClearGroups () {
    store.commit('CLEAR_GROUP')
  }

  onwhatsappReceiveGroups (data) {
    store.commit('UPDATE_GROUPS', data.groups)
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

  async requestMyCovers () {
    return this.post('requestMyCovers')
  }

  async changingCover (cover) {
    return this.post('changingCover', { cover: cover })
  }

  onchangePhoneCover (data) {
    store.commit('SET_CURRENT_COVER', { label: data.label, value: data.cover })
  }

  onreceiveCovers (data) {
    store.commit('UPDATE_MY_COVERS', data.covers)
  }

  async sendPicToUser (data) {
    return this.post('sendPicToUser', data)
  }

  async updateBluetooth (data) {
    return this.post('updateBluetooth', data)
  }

  async getClosestPlayers () {
    return this.post('getClosestPlayers')
  }

  async fetchDarkmessages () {
    return this.post('fetchDarkmessages')
  }

  async sendDarkMessage (message) {
    return this.post('sendDarkMessage', { message: message })
  }

  onsendDarkwebMessages (data) {
    store.commit('RECEIVE_DARK_MESSAGES', data)
  }

  async requestMyEmail () {
    return this.post('requestMyEmail')
  }

  onreceiveMyEmail (data) {
    store.commit('SETUP_MY_EMAIL', data.email)
  }

  async requestSentEmails (myEmail) {
    return this.post('requestSentEmails', myEmail)
  }

  onreceiveSentEmails (data) {
    store.commit('SETUP_SENT_EMAILS', data.emails)
  }

  async sendEmail (email) {
    Vue.notify({ sound: 'Email_Sound_Notification.ogg', hidden: true })
    return this.post('sendEmail', email)
  }

  async requestEmails () {
    return this.post('requestEmails')
  }

  onreceiveEmails (data) {
    store.commit('SETUP_EMAILS', data.emails)
  }

  async deleteEmail (emailID) {
    return this.post('deleteEmail', { emailID })
  }

  async registerEmail (email) {
    return this.post('registerEmail', email)
  }

  async fetchNews () {
    return this.post('fetchNews')
  }

  onsendRequestedNews (data) {
    store.commit('UPDATE_NEWS', data.news)
  }

  async postNews (pics, desc) {
    return this.post('postNews', { pics: pics, message: desc })
  }

  async requestJob () {
    return this.post('requestJob')
  }

  onreceiveNewsJob (data) {
    store.commit('UPDATE_JOB', data.job)
    store.commit('UPDATE_ACCESS', data.access)
  }

  async requestJobInfo () {
    return this.post('requestJobInfo')
  }

  async requestAziendaMessages () {
    return this.post('requestAziendaMessages')
  }

  async sendAziendaMessage (data) {
    // data.azienda, data.number, data.message
    return this.post('sendAziendaMessage', data)
  }

  async aziendaEmployesAction (data) {
    // data.action, data.employe
    return this.post('aziendaEmployesAction', data)
  }

  onreceiveAziendaCall (data) {
    if (data.notifications) { Vue.notify({ sound: 'msgnotify.ogg', hidden: true }) }
    store.commit('UPDATE_AZIENDA_CALLS', data.calls)
  }

  onupdateAziendaInfo (data) {
    store.commit('UPDATE_AZIENDA_APP', data)
  }

  onupdateAziendaMessages (data) {
    store.commit('UPDATE_AZIENDA_MESSAGES', data.messages)
  }

  onupdateAziendaEmployes (data) {
    store.commit('UPDATE_AZIENDA_EMPLOYES', data.employes)
  }

  async requestBourseProfile () {
    return this.post('requestBourseProfile')
  }

  async requestBourseCrypto () {
    return this.post('requestBourseCrypto')
  }

  onreceiveBourseProfile (data) {
    store.commit('UPDATE_BOURSE_PROFILE', data.profile)
  }

  onreceiveBourseCrypto (data) {
    store.commit('UPDATE_BOURSE_CRYPTO', data.crypto)
  }

  async buyCrypto (data) {
    return this.post('buyCrypto', data)
  }

  onreceiveMyCrypto (data) {
    store.commit('UPDATE_BOURSE_PERSONAL_CRYPTO', data.crypto)
  }

  async sellCrypto (data) {
    return this.post('sellCrypto', data)
  }

  /* YELLOW PAGES */

  async requestYellowPosts() {
    return this.post("requestYellowPosts")
  }

  onreceiveYellowPosts(data) {
    store.commit("RECEIVE_YELLOW_POSTS", data.posts)
  }

  async createYellowPost(data) {
    return this.post("createYellowPost", data)
  }
}

function decimalAdjust (type, value, exp) {
  if (typeof exp === 'undefined' || +exp === 0) { return Math[type](value) }
  value = +value
  exp = +exp
  if (isNaN(value) || !(typeof exp === 'number' && exp % 1 === 0)) { return NaN }
  value = value.toString().split('e')
  value = Math[type](+(value[0] + 'e' + (value[1] ? (+value[1] - exp) : -exp)))
  value = value.toString().split('e')
  return +(value[0] + 'e' + (value[1] ? (+value[1] + exp) : exp))
}

const instance = new PhoneAPI()

export default instance
