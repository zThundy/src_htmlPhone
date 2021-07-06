<template>
  <div style="width: 100%; height: 743px;" class="sfondo">
    <PhoneTitle :title="formatEmoji(this.gruppo.gruppo)" :titleColor="'black'" :backgroundColor="'rgb(112,255,125)'" @back="onBackspace"/>

    <div class="groupImage" data-type="button">
      <img :src="gruppo.icona" />
    </div>

    <div class="phone_fullscreen_img" v-if="imgZoom !== undefined">
      <img :src="imgZoom" />
    </div>

    <custom-toast class="toastPosition" :duration="1000" ref="updating">
      <md-activity-indicator
        :size="20"
        :text-size="16"
        color="white"
        text-color="white"
      >Aggiornamento...
      </md-activity-indicator>
    </custom-toast>

    <div style="width: 100%; height: 605px;" id='sms_list'>
      <div v-for="(s, i) of messaggi[String(gruppo.id)]" :key="i" class="whatsapp-menu-item">
        <div v-if="isSMSAudio(s)" style="overflow: auto;">
          <div v-if="isSentByMe(s)" class="bubble daMe" :class="{select: i === currentSelected}">
            <div class="whatsapp-audio-player">
              <div class="whatsapp-audio-player-title">
                <span>{{ s.sender }}</span>
              </div>
              <i class="fas fa-play"></i>
              <progress :id="'audio-progress-' + getSMSAudioInfo(s.message).id" max="100" value="0"></progress>
              <audio :id="'audio-player-' + getSMSAudioInfo(s.message).id"></audio>
            </div>
          </div>

          <div v-else class="bubble daAltri" :class="{select: i === currentSelected}">
            <div class="whatsapp-audio-player">
              <div class="whatsapp-audio-player-title">
                <span>{{ s.sender }}</span>
              </div>
              <i class="fas fa-play"></i>
              <progress :id="'audio-progress-' + getSMSAudioInfo(s.message).id" max="100" value="0"></progress>
              <audio :id="'audio-player-' + getSMSAudioInfo(s.message).id"></audio>
            </div>
          </div>
        </div>

        <div v-else-if="!isImage(s.message)" style="overflow: auto;">
          <div v-if="isSentByMe(s)" class="bubble daMe" :class="{select: i === currentSelected}">{{ s.sender }}: {{ formatEmoji(s.message) }}</div>
          <div v-else class="bubble daAltri" :class="{select: i === currentSelected}">{{ s.sender }}: {{ formatEmoji(s.message) }}</div>
        </div>

        <div v-else style="overflow: auto;">
          <img v-if="isSentByMe(s)" class="sms-img bubble daMe" :class="{select: i === currentSelected}" :src="s.message">
          <img v-else class="sms-img bubble daAltri" :class="{select: i === currentSelected}" :src="s.message">
        </div>
      </div>
    </div>

    <div class="whatsapp-write-input-container">
      <div class='whatsapp-write-input'>
        <input type="text" :placeholder="LangString('APP_WHATSAPP_PLACEHOLDER_ENTER_MESSAGE')" v-autofocus>
        <i v-if="!isRecording" class="fas fa-paper-plane"></i>
        <i v-else class="fas fa-microphone"></i>
      </div>
    </div>

  </div>
</template>


<script>
import { mapGetters, mapActions, mapMutations } from 'vuex'

import { ActivityIndicator } from 'mand-mobile'
import 'mand-mobile/lib/mand-mobile.css'

import CustomToast from '@/components/CustomToast'
import Modal from '@/components/Modal/index.js'
import PhoneTitle from './../PhoneTitle'

export default {
  name: 'whatsapp_selected_group',
  components: {
    PhoneTitle,
    CustomToast,
    [ActivityIndicator.name]: ActivityIndicator
  },
  data () {
    return {
      currentSelected: -1,
      ignoreControls: false,
      gruppo: [],
      imgZoom: undefined,
      isRecording: false,
      isPaused: false,
      isPlaying: false,
      chunks: [],
      audioElement: null
    }
  },
  computed: {
    ...mapGetters(['LangString', 'messaggi', 'myPhoneNumber', 'enableTakePhoto', 'contacts', 'config'])
  },
  methods: {
    ...mapActions(['requestWhatsappInfo', 'sendMessageInGroup']),
    ...mapMutations(['CHANGE_BRIGHTNESS_STATE']),
    formatEmoji (message) {
      return this.$phoneAPI.convertEmoji(message)
    },
    scrollIntoView () {
      this.$nextTick(() => {
        const elem = this.$el.querySelector('.select')
        if (elem !== null) {
          elem.scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' })
        }
      })
    },
    onUp () {
      if (this.ignoreControls === true) return
      if (this.currentSelected === -1) {
        this.currentSelected = this.messaggi[String(this.gruppo.id)].length - 1
      } else {
        this.currentSelected = this.currentSelected === 0 ? 0 : this.currentSelected - 1
      }
      this.scrollIntoView()
    },
    onDown () {
      if (this.ignoreControls === true) return
      if (this.currentSelected === -1) {
        this.currentSelected = this.messaggi[String(this.gruppo.id)].length - 1
      } else {
        this.currentSelected = this.currentSelected === this.messaggi[this.gruppo.id].length - 1 ? this.currentSelected : this.currentSelected + 1
      }
      this.scrollIntoView()
    },
    onBackspace () {
      if (this.imgZoom !== undefined) {
        this.imgZoom = undefined
        this.CHANGE_BRIGHTNESS_STATE(true)
        return
      }
      if (this.ignoreControls === true) { this.ignoreControls = false; return }
      if (this.currentSelected !== -1) { this.currentSelected = -1; return }
      this.$router.push({ name: 'whatsapp' })
    },
    async onRight () {
      if (this.isRecording) return
      if (this.ignoreControls === true) return
      // qui controllo se hai un messaggio selezionato
      // così da farti uscire le impostazioni di quel messaggio
      // oppure della chat
      if (this.currentSelected === -1) {
        try {
          this.ignoreControls = true
          let scelte = [
              {id: 'audio-record', title: this.LangString('APP_WHATSAPP_RECORD_AUDIO'), icons: 'fa-microphone'},
            {id: 1, title: this.LangString('APP_WHATSAPP_SEND_GPS'), icons: 'fa-location-arrow'},
            {id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red'}
          ]
          if (this.enableTakePhoto) {
            scelte = [
              {id: 'audio-record', title: this.LangString('APP_WHATSAPP_RECORD_AUDIO'), icons: 'fa-microphone'},
              {id: 1, title: this.LangString('APP_WHATSAPP_SEND_GPS'), icons: 'fa-location-arrow'},
              {id: 2, title: this.LangString('APP_WHATSAPP_SEND_PHOTO'), icons: 'fa-picture-o'},
              {id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red'}
            ]
          }
          const resp = await Modal.CreateModal({ scelte })
          switch (resp.id) {
            case 1:
              this.ignoreControls = false
              if (this.myPhoneNumber.includes('#') || this.myPhoneNumber === 0 || this.myPhoneNumber === '0') {
                this.$phoneAPI.onwhatsapp_showError({ title: 'Errore', message: 'Impossibile ottenere il numero di telefono' })
              } else {
                this.sendMessageInGroup({ gruppo: this.gruppo, message: '%pos%', phoneNumber: this.myPhoneNumber })
              }
              break
            case 2:
              this.ignoreControls = false
              const { url } = await this.$phoneAPI.takePhoto()
              if (url !== null && url !== undefined) { this.sendMessageInGroup({ gruppo: this.gruppo, message: url, phoneNumber: this.myPhoneNumber }) }
              break
            case -1:
              this.ignoreControls = false
              break
            case 'audio-record':
              this.ignoreControls = false
              this.start()
              break
          }
        } catch (e) {}
      } else {
        this.onActionMessage(this.messaggi[String(this.gruppo.id)][this.currentSelected])
      }
    },
    isImage (message) {
      return this.$phoneAPI.isImage(message)
    },
    isSMSAudio (mess) {
      return mess.message.indexOf('[AUDIO]') === 0
    },
    getSMSAudioInfo (mess) {
      var obj = mess.split('%')
      return {
        id: obj[2],
        number: obj[1]
      }
    },
    onEnter () {
      if (this.isPlaying) {
        this.audioElement.pause()
        this.audioElement = null
        return
      }
      if (this.isRecording) {
        this.stop()
        this.saveAudio()
        this.ignoreControls = false
        return
      }
      if (this.ignoreControls === true) return
      this.$phoneAPI.getReponseText({ title: 'Invia un messaggio' }).then(data => {
        let message = data.text.trim()
        if (message !== '') {
          if (this.myPhoneNumber.includes('#') || this.myPhoneNumber === 0 || this.myPhoneNumber === '0') {
            this.$phoneAPI.onwhatsapp_showError({ title: 'Errore', message: 'Impossibile ottenere il numero di telefono' })
          } else {
            this.sendMessageInGroup({ gruppo: this.gruppo, message: message, phoneNumber: this.myPhoneNumber })
          }
          setTimeout(() => {
            this.currentSelected = this.messaggi[String(this.gruppo.id)].length - 1
            this.scrollIntoView()
          }, 200)
        }
      })
    },
    listenAudio (message) {
      setTimeout(() => {
        let audioInfo = this.getSMSAudioInfo(message)
        fetch('http://' + this.config.fileUploader.ip + ':3000/audioDownload?type=whatsapp&key=' + audioInfo.id, {
          method: 'GET'
        }).then(async resp => {
          if (resp.status === 404) { return console.err('404 error') }
          const progressElement = document.getElementById('audio-progress-' + audioInfo.id)
          this.audioElement = document.getElementById('audio-player-' + audioInfo.id)
          var jsonResponse = await resp.json()
          this.audioElement.src = window.URL.createObjectURL(new Blob([Buffer.from(jsonResponse.blobDataBuffer, 'base64')]))
          // this.audioElement.src = window.URL.createObjectURL(await resp.blob())
          this.audioElement.load()
          this.audioElement.currentTime = 24 * 60 * 60
          this.audioElement.onloadeddata = async () => {
            this.audioElement.currentTime = 0
            this.audioElement.ontimeupdate = () => {
              if (this.audioElement) {
                if (this.audioElement.duration === Infinity || isNaN(this.audioElement.duration)) return
                progressElement.value = (this.audioElement.currentTime / this.audioElement.duration) * 100
                if (this.audioElement.currentTime === this.audioElement.duration) { this.isPlaying = false }
              }
            }
          }
          this.audioElement.play()
          this.isPlaying = true
        }).catch(() => {})
      }, 500)
    },
    async start () {
      try {
        this.$_stream = await this.getStream()
        this.prepareRecorder()
        this.$_mediaRecorder.start()
      } catch (e) {}
    },
    stop () {
      this.$_mediaRecorder.stop()
      this.$_stream.getTracks().forEach(t => t.stop())
    },
    async getStream () {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true, video: false })
      return stream
    },
    prepareRecorder () {
      if (!this.$_stream) { return }
      this.$_mediaRecorder = new MediaRecorder(this.$_stream)
      this.$_mediaRecorder.ignoreMutedMedia = true
      this.$_mediaRecorder.addEventListener('start', () => {
        this.isRecording = true
        this.isPaused = false
      })
      this.$_mediaRecorder.addEventListener('resume', () => {
        this.isRecording = true
        this.isPaused = false
      })
      this.$_mediaRecorder.addEventListener('pause', () => {
        this.isPaused = true
      })
      this.$_mediaRecorder.addEventListener('dataavailable', (e) => {
        if (e.data && e.data.size > 0) {
          this.chunks.push(e.data)
        }
      }, true)
    },
    saveAudio () {
      setTimeout(() => {
        const blobData = new Blob(this.chunks, { 'type': 'audio/ogg;codecs=opus' })
        if (blobData.size > 0) {
          const id = this.$phoneAPI.makeid(15)
          const formData = new FormData()
          formData.append('audio-file', blobData)
          formData.append('filename', id)
          formData.append('type', 'whatsapp')
          fetch('http://' + this.config.fileUploader.ip + ':3000/audioUpload', {
            method: 'POST',
            body: formData
          }).then(() => {
            this.sendMessageInGroup({ gruppo: this.gruppo, message: '[AUDIO]%' + this.myPhoneNumber + '%' + id, phoneNumber: this.myPhoneNumber })
            this.isPaused = false
            this.isRecording = false
          })
        }
        this.chunks = []
      }, 500)
    },
    isSentByMe (messaggio) {
      if (messaggio.sender === this.myPhoneNumber) return true
      return false
    },
    async onActionMessage (message) {
      try {
        let isGPS = /(-?\d+(\.\d+)?), (-?\d+(\.\d+)?)/.test(message.message)
        let scelte = [
              {id: 'audio-record', title: this.LangString('APP_WHATSAPP_RECORD_AUDIO'), icons: 'fa-microphone'},
          { id: 1, title: this.LangString('APP_WHATSAPP_SEND_GPS'), icons: 'fa-location-arrow' },
          { id: 2, title: this.LangString('APP_WHATSAPP_SEND_PHOTO'), icons: 'fa-picture-o' },
          { id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' }
        ]
        if (isGPS === true) { scelte = [{ id: 'gps', title: this.LangString('APP_WHATSAPP_SET_GPS'), icons: 'fa-location-arrow' }, ...scelte] }
        if (this.isImage(message.message)) { scelte = [{ id: 'zoom', title: this.LangString('APP_MESSAGE_ZOOM_IMG'), icons: 'fa-search' }, ...scelte] }
        if (this.isSMSAudio(message)) {
          scelte = [{ id: 'audio-listen', title: this.LangString('APP_WHATSAPP_LISTEN_AUDIO'), icons: 'fa-headphones' }, ...scelte]
        }
        this.ignoreControls = true
        const data = await Modal.CreateModal({ scelte })
        this.ignoreControls = false
        if (data.id === 'gps') {
          let val = message.message.match(/(-?\d+(\.\d+)?), (-?\d+(\.\d+)?)/)
          this.$phoneAPI.setGPS(val[1], val[3])
        } else if (data.id === 'zoom') {
          this.CHANGE_BRIGHTNESS_STATE(false)
          this.imgZoom = message.message
        } else if (data.id === 'audio-listen') {
          this.listenAudio(message.message)
        } else if (data.id === 'audio-record') {
          this.start()
        } else if (data.id === 1) {
          if (this.myPhoneNumber.includes('#') || this.myPhoneNumber === 0 || this.myPhoneNumber === '0') {
            this.$phoneAPI.onwhatsapp_showError({ title: 'Errore', message: 'Impossibile ottenere il numero di telefono' })
          } else {
            this.sendMessageInGroup({ gruppo: this.gruppo, message: '%pos%', phoneNumber: this.myPhoneNumber })
          }
        } else if (data.id === 2) {
          const pic = await this.$phoneAPI.takePhoto()
          if (pic !== null && pic !== undefined) { this.sendMessageInGroup({ gruppo: this.gruppo, message: pic.url, phoneNumber: this.myPhoneNumber }) }
        }
      } catch (e) { }
    },
    async startUpdatingMessages () {
      this.$refs.updating.show()
      this.ignoreControls = true
      setTimeout(() => {
        this.currentSelected = this.messaggi[String(this.gruppo.id)].length - 1
        this.scrollIntoView()
        this.ignoreControls = false
      }, 1000)
    }
  },
  created () {
    if (this.$route.params.updategroups) { this.$phoneAPI.requestInfoOfGroups() }
    this.gruppo = this.$route.params.gruppo
    this.requestWhatsappInfo({ groupId: this.gruppo.id, contacts: this.contacts })
    setTimeout(() => {
      this.startUpdatingMessages()
    }, 100)
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpEnter', this.onEnter)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpEnter', this.onEnter)
  }
}
</script>

<style scoped>
.sfondo {
  background-image: url("/html/static/img/app_whatsapp/sfondogruppi.png");
  background-repeat: no-repeat;
  width: auto;
  height: auto;
  margin: 0;
  padding: 0;
  position: absolute;
}

.whatsapp-menu-item {
  flex-grow: 1;
  flex-basis: 0;
  height: auto;
}

/* Input message zone */

#sms_list{
  height: calc(100% - 34px - 26px);
  overflow-y: hidden;
  padding-bottom: 8px;
}

.whatsapp-write-input-container {
  width: 330px;
  height: 50px;
  position: relative;
}

.whatsapp-write-input {
  position: relative;
  height: 40px;
  width: 90%;
  background-color: #e9e9eb;
  border-radius: 56px;
  margin-left: auto;
  margin-right: auto;
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.6);
}

.whatsapp-write-input input {
  height: 100%;
  border: none;
  outline: none;
  font-size: 15px;
  margin-left: 14px;
  padding: 12px 5px;
  background-color: rgba(236, 236, 241, 0)
}

.whatsapp-write-input i {
  height: 50px;
  width: 50px;
  font-size: 15px;
  bottom: 5px;
  color: #e2e2e2;
  float: right;
  position: relative;
  padding-top: 16px;
  border-radius: 50px;
  text-align-last: center;
  background-color: rgb(0, 139, 12);
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.6);
  transition: all .5s ease;
}

.sms-img {
  width: 80%;
  height: auto;
  padding-top: 12px;
  border-radius: 19px;
}

/* IMMAGINE DEL GRUPPO */

.groupImage {
  position: inherit;
  
  top: 35.5px;
  right: 16px;
}

.groupImage img {
  object-fit: cover;

  border-radius: 50%;
  border: 2px solid rgb(117, 117, 117);

  height: 40px;
  width: 40px;
}

/* css bolle dei messaggi */

.bubble {
  background-color: #F2F2F2;
  border-radius: 5px;
  box-shadow: 0 0 7px #868686;
  display: inline-block;
  padding: 10px 18px;
  position: relative;
  vertical-align: top;
}

.bubble::before {
  background-color: #F2F2F2;
  content: "\00a0";
  display: block;
  height: 16px;
  position: absolute;
  top: 11px;
  transform:             rotate( 29deg ) skew( -35deg );
      -moz-transform:    rotate( 29deg ) skew( -35deg );
      -ms-transform:     rotate( 29deg ) skew( -35deg );
      -o-transform:      rotate( 29deg ) skew( -35deg );
      -webkit-transform: rotate( 29deg ) skew( -35deg );
  width:  20px;
}

.daAltri {
  float: left;
  margin: 5px 45px 5px 20px;
}

.daAltri::before {
  box-shadow: -2px 2px 2px 0 rgba( 178, 178, 178, .4 );
  left: -9px;
}

.daAltri.select { background-color: rgb(230, 230, 230); }
.daAltri.select::before { background-color: rgb(230, 230, 230); }

.daMe {
  float: right;
  margin: 5px 20px 5px 45px;
  background-color: rgb(162, 255, 175);     
}

.daMe::before {
  box-shadow: 2px -2px 2px 0 rgba( 178, 178, 178, .4 );
  right: -9px;
  background-color: rgb(162, 255, 175); 
}

.daMe.select { background-color: rgb(118, 255, 137); }
.daMe.select::before { background-color: rgb(118, 255, 137); }

.toastPosition {
  bottom: 40px;
}

.whatsapp-audio-player {
  width: 200px;
  height: 60px;
  transition: all .5s ease;
}

.whatsapp-audio-player-title {
  position: relative;
  width: 100%;
  height: 20px;
}

.whatsapp-audio-player-title span {
  position: relative;
  font-size: 15px;
  color: gray;
  padding-bottom: 10px;
}

.whatsapp-audio-player progress {
  position: relative;
  width: 160px;
  margin-left: 10px;
  margin-bottom: 3px;
  transition: all .5s ease;
}

.whatsapp-audio-player i {
  font-size: 20px;
  color: rgb(189, 189, 189);
  margin-top: 10px;
  position: relative;
  transition: all .5s ease;
}

</style>
