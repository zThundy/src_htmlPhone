import store from '@/store'
import VoiceRTC from './VoiceRTC'
import VideoRTC from './VideoRTC'
import Vue from 'vue'
import { Howl, Howler } from 'howler'
import aes256 from 'aes256'

import emoji from './emoji.json'
const keyEmoji = Object.keys(emoji)

let USE_VOICE_RTC = false
const BASE_URL = 'https://zth_gcphone/'

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
    this.videoRTC = null
    this.soundList = {}
    this.audioElement = new Audio()
    this.stream = null
    this.mediaRecorder = null
    this.isRecordingVoiceMail = false
    this.playingVoiceMailAudio = false
    this.chunks = []
    this.voicemailTarget = null
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

  onphoneChecks (data) {
    // store.dispatch('isPhoneLoaded', { key: this.config.authKey, req: data.req })
    try {
      var key = data.key
      var req = data.req
      if (req && key) {
        var decrypted = aes256.decrypt(key, req)
        decrypted = JSON.parse(decrypted)
        if (decrypted) {
          if (decrypted.license === key && decrypted.text === 'STATUS_OK') {
            store.commit('SET_LOADED_VALUE', true)
            this.post('PhoneNeedAuth', false)
          } else {
            store.commit('SET_LOADED_VALUE', false)
            this.post('PhoneNeedAuth', true)
          }
        } else {
          this.post('PhoneNeedAuth', true)
        }
      } else {
        this.post('PhoneNeedAuth', true)
      }
    } catch (e) { console.log(e) }
  }

  getEmojis () {
    return emoji
  }

  convertEmoji (text) {
    if (text) {
      for (const e of keyEmoji) {
        text = text.replace(new RegExp(`:${e}:`, 'g'), emoji[e])
      }
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

  // == Gestion des appels
  async deletePhoneHistory (numero) {
    return this.post('deletePhoneHistory', { numero })
  }

  async deleteAllPhoneHistory () {
    return this.post('deleteAllPhoneHistory')
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
      if (this.config.enableWebRTC === true) {
        this.voiceRTC = new VoiceRTC(this.config.RTCConfig, this.config.RTCFilters)
        this.videoRTC = new VideoRTC(this.config.RTCConfig)
        USE_VOICE_RTC = true
      }
      this.notififyUseRTC(this.config.enableWebRTC)
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

  /*
    transmitter = transmitter,
    receiver = receiver,
    message = message,
    isRead = owner,
    owner = owner,
    id = id
  */

  ongenericNotification (data) {
    Vue.notify({
      message: store.getters.LangString(data.notif.message),
      title: store.getters.LangString(data.notif.title) + ':',
      icon: data.notif.icon,
      backgroundColor: data.notif.color,
      appName: data.notif.appName,
      sound: data.notif.sound
    })
  }

  onnewMessage (data) {
    store.commit('ADD_MESSAGE', data.message)
    if (!data.message.owner) {
      Vue.notify({
        message: data.message.message,
        title: data.message.receiver + ':',
        icon: 'envelope',
        backgroundColor: 'rgb(255, 140, 30)',
        appName: 'Messaggi'
      })
    }
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

  // Video Calls
  async startVideoCall (numero, extraData = undefined) {
    if (USE_VOICE_RTC === true) {
      const rtcOffer = await this.videoRTC.prepareCall()
      return this.post('startVideoCall', { numero, rtcOffer, extraData })
    } else {
      return this.sendErrorMessage(store.getters.LangString('PHONE_RTC_NOT_ENABLED'))
    }
  }

  async acceptVideoCall (infoCall) {
    if (USE_VOICE_RTC === true) {
      const rtcAnswer = await this.videoRTC.acceptCall(infoCall)
      return this.post('acceptVideoCall', { infoCall, rtcAnswer })
    } else {
      return this.sendErrorMessage(store.getters.LangString('PHONE_RTC_NOT_ENABLED'))
    }
  }

  async rejectVideoCall (infoCall) {
    return this.post('rejectVideoCall', { infoCall })
  }

  onwaitingVideoCall (data) {
    store.commit('SET_APPELS_INFO_IF_EMPTY', {
      ...data.infoCall,
      initiator: data.initiator
    })
  }

  onacceptVideoCall (data) {
    if (USE_VOICE_RTC === true) {
      if (data.initiator === true) {
        this.voiceRTC.onReceiveAnswer(data.infoCall.rtcAnswer)
      }
      this.voiceRTC.addEventListener('onCandidate', (candidates) => {
        this.post('onVideoCandidates', { id: data.infoCall.id, candidates })
      })
    }
    store.commit('SET_APPELS_INFO_IS_ACCEPTS', true)
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

  async oninitVoiceMail (infoCall) {
    // fetch di phone_number
    const volume = infoCall.infoCall.volume
    this.voicemailTarget = infoCall.infoCall.receiver_num
    fetch('http://localhost:3000/audioDownload?type=voicemails&key=' + infoCall.infoCall.receiver_num, {
      method: 'GET'
    }).then(async resp => {
      console.log(resp.status)
      if (resp.status === 404) {
        this.onplaySound({ sound: 'segreteriaDefault.ogg', volume: volume })
        this.playingVoiceMailAudio = true
        setTimeout(() => {
          this.onstopSound({sound: 'segreteriaDefault.ogg'})
          this.playingVoiceMailAudio = false
          this.startVoiceMailRecording()
        }, 7500)
      } else {
        const blobData = await resp.blob()
        this.audioElement.src = window.URL.createObjectURL(blobData)
        this.audioElement.load()
        this.audioElement.onloadeddata = async () => {
          this.audioElement.currentTime = 0
          this.audioElement.ontimeupdate = () => {
            if (this.audioElement.currentTime === this.audioElement.duration) {
              this.playVoiceMailBeep(volume)
              this.playingVoiceMailAudio = false
            }
          }
        }
        this.audioElement.play()
        this.playingVoiceMailAudio = true
      }
    })
    return this.post('acceptCall', { infoCall })
  }

  async playVoiceMailBeep (volume) {
    this.onplaySound({sound: 'voiceMailBeep.ogg', volume: volume})
    setTimeout(() => {
      this.onstopSound({sound: 'voiceMailBeep.ogg'})
      this.startVoiceMailRecording()
    }, 500)
  }

  async startVoiceMailRecording () {
    if (this.isRecordingVoiceMail) { return }
    this.isRecordingVoiceMail = true
    try {
      this.stream = await this.getStream()
      this.prepareRecorder()
      this.mediaRecorder.start()
    } catch (e) {
      // this.$emit('error', e)
      // eslint-disable-next-line
      console.error(e)
    }
  }

  async stopVoiceMailRecording () {
    this.mediaRecorder.stop()
    this.mediaRecorder = null
  }

  async getStream () {
    const stream = await navigator.mediaDevices.getUserMedia({ audio: true, video: false })
    // this.$emit('stream', stream)
    return stream
  }

  async prepareRecorder () {
    if (!this.stream) { return }
    this.mediaRecorder = new MediaRecorder(this.stream)
    this.mediaRecorder.ignoreMutedMedia = true
    this.mediaRecorder.addEventListener('dataavailable', (e) => {
      if (e.data && e.data.size > 0) {
        // console.log(e.data)
        this.chunks.push(e.data)
      }
    }, true)
    this.mediaRecorder.addEventListener('stop', (e) => {
      this.isRecordingVoiceMail = false
      this.stream.getTracks().forEach(t => t.stop())
      this.stream = null
      this.audioElement.src = ''
      this.saveRecordedVoiceMail()
    }, true)
  }

  async saveRecordedVoiceMail () {
    // console.log('chunks', this.chunks)
    const blobData = new Blob(this.chunks, { 'type': 'audio/ogg;codecs=opus' })
    // console.log('blobData', blobData.size)
    if (blobData.size > 0) {
      // console.log('dimensione del blob maggiore di 0')
      const formData = new FormData()
      formData.append('audio-file', blobData)
      formData.append('filename', this.makeid(15))
      formData.append('type', 'voicemails_messages')
      formData.append('voicemail_target', this.voicemailTarget)
      fetch('http://localhost:3000/audioUpload', {
        method: 'POST',
        body: formData
      })
    }
    this.chunks = []
  }

  makeid (length) {
    var result = ''
    var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    var charactersLength = characters.length
    for (var i = 0; i < length; i++) {
      result += characters.charAt(Math.floor(Math.random() * charactersLength))
    }
    return result
  }

  async rejectCall (infoCall) {
    if (this.playingVoiceMailAudio) {
      this.onstopSound({sound: 'segreteriaDefault.ogg'})
      if (this.audioElement !== null) {
        this.audioElement.pause()
        this.audioElement.src = ''
      }
      this.playingVoiceMailAudio = false
    }
    if (this.isRecordingVoiceMail) {
      this.stopVoiceMailRecording()
      this.isRecordingVoiceMail = false
    }
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

  // async endSuoneriaForOthers () {
  //   return this.post('endSuoneriaForOthers')
  // }

  // async startSuoneriaForOthers (sound) {
  //   return this.post('startSuoneriaForOthers', { sound: sound })
  // }

  onplaySound (data) {
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
        loop: true
        // onend: function () { delete this.soundList[data.sound] }
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

  // ontwitter_showError (data) {
  //   Vue.notify({
  //     title: store.getters.LangString(data.title),
  //     message: store.getters.LangString(data.message),
  //     icon: 'twitter',
  //     backgroundColor: 'rgb(80, 160, 230)',
  //     appName: 'Twitter'
  //   })
  // }

  // ontwitter_showSuccess (data) {
  //   Vue.notify({
  //     title: store.getters.LangString(data.title),
  //     message: store.getters.LangString(data.message),
  //     icon: 'twitter',
  //     backgroundColor: 'rgb(80, 160, 230)',
  //     appName: 'Twitter'
  //   })
  // }

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
    // Vue.notify({ sound: 'phoneUnlock.ogg', hidden: true, duration: 1500 })
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
    Vue.notify({ sound: 'Instagram_Like_Sound.ogg', hidden: true })
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
  // oninstagram_showError (data) {
  //   Vue.notify({
  //     title: store.getters.LangString(data.title),
  //     message: store.getters.LangString(data.message),
  //     icon: 'instagram',
  //     backgroundColor: 'rgb(255, 204, 0)',
  //     sound: 'Instagram_Error.ogg',
  //     appName: 'Instagram'
  //   })
  // }

  // notifica di successo
  // oninstagram_showSuccess (data) {
  //   Vue.notify({
  //     title: store.getters.LangString(data.title),
  //     message: store.getters.LangString(data.message),
  //     icon: 'instagram',
  //     backgroundColor: 'rgb(255, 204, 0)',
  //     sound: 'Instagram_Notification.ogg',
  //     appName: 'Instagram'
  //   })
  // }

  // ///////////////////////// //
  // SEZIONE WHATSAPP TELEFONO //
  // ///////////////////////// //

  // notifica di errore
  // onwhatsapp_showError (data) {
  //   Vue.notify({
  //     title: store.getters.LangString(data.title),
  //     message: store.getters.LangString(data.message),
  //     icon: 'whatsapp',
  //     backgroundColor: 'rgb(90, 200, 105)',
  //     sound: 'Whatsapp_Message_Sound.ogg',
  //     appName: 'Whatsapp'
  //   })
  // }

  // notifica di successo
  // onwhatsapp_showSuccess (data) {
  //   Vue.notify({
  //     title: store.getters.LangString(data.title),
  //     message: store.getters.LangString(data.message),
  //     icon: 'whatsapp',
  //     backgroundColor: 'rgb(90, 200, 105)',
  //     sound: 'Whatsapp_Message_Sound.ogg',
  //     appName: 'Whatsapp'
  //   })
  // }

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
    store.commit('SET_CURRENT_COVER', { label: data.label, value: data.cover })
  }

  onreceiveCovers (data) {
    store.commit('UPDATE_MY_COVERS', data.covers)
  }

  // ////////////////////////// //
  // SEZIONE BLUETOOTH TELEFONO //
  // ////////////////////////// //

  async sendPicToUser (data) {
    return this.post('sendPicToUser', data)
  }

  async updateBluetooth (data) {
    return this.post('updateBluetooth', data)
  }

  async getClosestPlayers () {
    return this.post('getClosestPlayers')
  }
  // onsendClosestPlayers (users) {
  //   store.commit('UPDATE_CLOSEST_PLAYERS', users)
  // }

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

  // ////////////// //
  // EMAIL FUNZIONI //
  // ////////////// //

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

  // ///////////// //
  // NEWS FUNZIONI //
  // ///////////// //

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
  }

  // //////////////// //
  // AZIENDA FUNZIONI //
  // //////////////// //

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

  // ////////////// //
  // BORSA FUNZIONI //
  // ////////////// //

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
