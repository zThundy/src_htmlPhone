<template>
  <div style="width: 100%; height: 100%;"  class="phone_app">
    <div class="backblur" v-bind:style="{ background: 'url(' + backgroundURL +')' }"></div>
    <InfoBare />
    <div class="num">{{ appelsDisplayNumber }}</div>
    <div class="contactName">{{ formatEmoji(appelsDisplayName) }}</div>

    <div class="time"></div>
    <div class="time-display">{{ timeDisplay }}</div>

    <div class="actionbox">
      <div class="action hangup" :class="{ disableTrue: status === 0 && select !== 0 }">
        <i class="fas fa-phone"></i>
      </div>
      <div class="action answer" v-if="status === 0" :class="{ disableFalse: status === 0 && select !== 1 }">
        <i class="fas fa-phone"></i>
      </div>
    </div>

    <div class="keypad-general-container" :style="[ showingKeypad ? { bottom: '0px' } : {} ]">
      <div class="extra-content-line"></div>

      <div class="keypad-general-input">
        <input :placeholder="LangString('APP_PHONE_KEYPAD_PLACEHOLDER')" :value="numero"/>
      </div>

      <div class="keyboard">
        <div class="key" v-for="(key, i) of keyInfo" :key="key.primary" :class="{ 'key-select': i === keySelect, 'keySpe': key.isNotNumber === true }">
          <span class="key-primary">{{ key.primary }}</span>
          <span class="key-secondary">{{ key.secondary }}</span>
        </div>
      </div>
    </div>

   </div>
</template>

<script>
// eslint-disable-next-line
import { mapGetters, mapActions } from 'vuex'
import InfoBare from './../InfoBare'
export default {
  components: { InfoBare },
  data () {
    return {
      time: -1,
      intervalNum: undefined,
      select: -1,
      status: 0,
      showingKeypad: false,
      numero: '',
      keySelect: 0,
      keyInfo: [
        {primary: '1', secondary: '', ascii: 48},
        {primary: '2', secondary: 'abc', ascii: 49},
        {primary: '3', secondary: 'def', ascii: 50},
        {primary: '4', secondary: 'ghi', ascii: 51},
        {primary: '5', secondary: 'jkl', ascii: 52},
        {primary: '6', secondary: 'mmo', ascii: 53},
        {primary: '7', secondary: 'pqrs', ascii: 54},
        {primary: '8', secondary: 'tuv', ascii: 55},
        {primary: '9', secondary: 'wxyz', ascii: 56},
        {primary: '*', secondary: '', isNotNumber: true, ascii: 42},
        {primary: '0', secondary: '+', ascii: 57},
        {primary: '#', secondary: '', isNotNumber: true, ascii: 35}
      ],
      stream: null,
      mediaRecorder: null,
      isRecordingVoiceMail: false,
      voicemailTarget: null,
      playingSound: false,
      voicemailMenuIndex: 0,
      listeningToVoiceMailMessages: false,
      recordedMessagesIndex: 0,
      recordedMessagesCache: null,
      audioElement: new Audio(),
      keyAudioElement: new Audio(),
      chunks: []
    }
  },
  methods: {
    ...mapActions(['acceptCall', 'rejectCall', 'ignoreCall']),
    formatEmoji (message) {
      return this.$phoneAPI.convertEmoji(message)
    },
    onBackspace () {
      if (this.showingKeypad) {
        this.showingKeypad = false
        return
      }
      if (this.status === 1) { this.onRejectCall() } else { this.onIgnoreCall() }
    },
    onEnter () {
      if (this.showingKeypad) {
        this.$phoneAPI.playKeySound({ file: this.keyInfo[this.keySelect].ascii })
        this.keyDigitEvent({ pressedKey: this.keyInfo[this.keySelect].primary })
        if (this.numero.length >= 25) this.numero = ''
        this.numero += this.keyInfo[this.keySelect].primary
        return
      }
      if (this.status === 0) { this.onAcceptCall() }
    },
    onUp () {
      if (!this.showingKeypad) { this.showingKeypad = true; return }
      if (this.keySelect > 2) {
        this.keySelect = this.keySelect - 3
      }
    },
    onDown () {
      if (!this.showingKeypad) return
      if (this.keySelect > 8) return
      this.keySelect = Math.min(this.keySelect + 3, 11)
    },
    onLeft () {
      if (!this.showingKeypad) return
      this.keySelect = Math.max(this.keySelect - 1, 0)
    },
    onRight () {
      if (!this.showingKeypad) return
      this.keySelect = Math.min(this.keySelect + 1, 11)
    },
    onRejectCall () {
      this.rejectCall()
    },
    onAcceptCall () {
      this.acceptCall()
    },
    onIgnoreCall () {
      this.ignoreCall()
      this.$router.push({ name: 'menu' })
    },
    startTimer () {
      if (this.intervalNum === undefined) {
        this.time = 0
        this.intervalNum = setInterval(() => { this.time += 1 }, 1000)
      }
    },
    // SEGRETERIA //
    async tts (text, cb, instance) {
      if (text === '') { return cb(instance) }
      instance.playSound({ sound: 'tts/' + text.charAt(0) + '.ogg', delay: 100 }, function (instance) {
        text = text.substring(1, text.length)
        instance.tts(text, cb, instance)
      })
    },
    async initVoiceMailListener () {
      this.listeningToVoiceMailMessages = true
      this.playSound({ sound: 'voiceMailWelcomerPartOne.ogg' }, function (instance) {
        instance.tts(instance.myPhoneNumber.toString(), function (instance) {
          instance.playSound({ sound: 'voiceMailWelcomerPartTwo.ogg' })
        }, instance)
      })
    },
    async keyDigitEvent (data) {
      if (!this.listeningToVoiceMailMessages) { return }
      var pressedKey = Number(data.pressedKey)
      if (this.voicemailMenuIndex === 0) {
        if (isNaN(data.pressedKey)) return
        if (pressedKey === 1) {
          this.getAvailableRecordedMessages({ sourceNumber: this.myPhoneNumber }, function (data) {
            if (data.response === undefined) {
              data.instance.finishVoiceMailCall()
            } else {
              data.instance.recordedMessagesCache = data.response
              data.instance.voicemailMenuIndex = pressedKey
              data.instance.playSound({ sound: 'voiceMailMessageOptions.ogg' })
            }
          })
        } else if (pressedKey === 2) {
          this.voicemailMenuIndex = pressedKey
          this.playSound({ sound: 'voiceMailEmptyOptions.ogg' })
        } else if (pressedKey === 3) {
          this.playSound({ sound: 'voiceMailWelcomerPartTwo.ogg' })
        }
      } else if (this.voicemailMenuIndex === 1) {
        if (pressedKey === 1) {
          this.playSound({ sound: 'recordedMessageFrom.ogg' }, function (instance) {
            var currentRecordedMessage = instance.recordedMessagesCache[instance.recordedMessagesIndex]
            instance.tts(currentRecordedMessage.sourceNumber, function (instance) {
              var blobData = new Blob([Buffer.from(currentRecordedMessage.blobDataBuffer, 'base64')])
              instance.playSound({ path: window.URL.createObjectURL(blobData) }, function (instance) {
                instance.playSound({ sound: 'recordedMessageEnd.ogg' })
              })
            }, instance)
          })
        } else if (pressedKey === 2) {
          if (this.recordedMessagesCache[(this.recordedMessagesIndex + 1)] !== undefined) {
            this.playSound({ sound: 'voiceMailMessageOptions.ogg' })
            this.recordedMessagesIndex++
          } else {
            this.playSound({ sound: 'noRecordedMessagesLeft.ogg' }, function (instance) {
              instance.finishVoiceMailCall()
            })
          }
        } else if (pressedKey === 3) {
          this.deleteCurrentRecordedVoiceMail()
        } else if (pressedKey === 4) {
          this.recordedMessagesIndex = 0
          this.voicemailMenuIndex = 0
          this.playSound({ sound: 'voicemailWelcomerPartTwo.ogg' })
        } else if (pressedKey === 5) {
          this.playSound({ sound: 'voiceMailMessageOptions.ogg' })
        }
      } else if (this.voicemailMenuIndex === 2) {
        if (pressedKey === 1) {
          this.recordedMessagesIndex = 'all'
          this.deleteCurrentRecordedVoiceMail()
        } else if (pressedKey === 2) {
          this.recordedMessagesIndex = 0
          this.voicemailMenuIndex = 0
          this.playSound({ sound: 'voicemailWelcomerPartTwo.ogg' })
        } else if (pressedKey === 3) {
          this.playSound({ sound: 'voiceMailEmptyOptions.ogg' })
        }
      }
    },
    async getAvailableRecordedMessages (data, cb) {
      fetch('http://' + this.config.fileUploader.ip + ':3000/getAvailabledRecordedMessages?index=' + this.recordedMessagesIndex + '&target=' + data.sourceNumber, {
        method: 'GET'
      }).then(async resp => {
        if (resp.status === 404) {
          this.playSound({ sound: 'noRecordedMessagesLeft.ogg' }, function (instance) {
            cb({ instance: instance })
          })
        } else {
          const jsonResponse = await resp.json()
          cb({ response: jsonResponse, instance: this })
        }
      })
    },
    async deleteCurrentRecordedVoiceMail () {
      const formData = new FormData()
      formData.append('index', this.recordedMessagesIndex)
      formData.append('voicemail_target', this.myPhoneNumber)
      fetch('http://' + this.config.fileUploader.ip + ':3000/recordedMessageDelete', {
        method: 'POST',
        body: formData
      })
      this.recordedMessagesCache = this.recordedMessagesIndex === 'all' ? [] : this.$phoneAPI.removeElementAtIndex(this.recordedMessagesCache, this.recordedMessagesIndex)
      if (this.recordedMessagesCache.length === 0) {
        this.playSound({ sound: 'noRecordedMessagesLeft.ogg' }, function (instance) {
          instance.finishVoiceMailCall()
        })
      } else {
        this.recordedMessagesIndex = this.recordedMessagesIndex - 1 < 0 ? 0 : this.recordedMessagesIndex - 1
        this.playSound({ sound: 'voiceMailMessageOptions.ogg' })
      }
    },
    async finishVoiceMailCall () {
      this.stopSound()
      this.voicemailMenuIndex = 0
      this.recordedMessagesIndex = 0
      this.listeningToVoiceMailMessages = false
      this.onRejectCall()
    },
    async playSound (data, cb) {
      if (this.audioElement.src !== '' && this.audioElement.src !== 'http://localhost:8080/' && this.playingSound) { this.audioElement.pause() }
      if (data.volume !== undefined) this.audioElement.volume = data.volume
      this.audioElement.src = data.path === undefined ? '/html/static/sound/' + data.sound : data.path
      this.audioElement.onloadeddata = async () => {
        this.audioElement.currentTime = 0
        this.audioElement.onended = () => {
          this.playingSound = false
          this.audioElement.src = ''
          if (cb !== undefined) { cb(this) }
        }
      }
      this.audioElement.play()
      this.playingSound = true
    },
    async stopSound () {
      if (this.audioElement.src !== '' && this.audioElement.src !== 'http://localhost:8080/') { this.audioElement.pause() }
    },
    async initVoiceMail (data) {
      const volume = data.volume
      this.voicemailTarget = data.receiver_num
      fetch('http://' + this.config.fileUploader.ip + ':3000/audioDownload?type=voicemails&key=' + data.receiver_num, {
        method: 'GET'
      }).then(async resp => {
        if (resp.status === 404) {
          this.playSound({ sound: 'segreteriaDefault.ogg', volume: volume }, function (instance) {
            instance.startVoiceMailRecording()
          })
        } else {
          const blobData = await resp.json()
          this.playSound({ path: window.URL.createObjectURL(new Blob([Buffer.from(blobData.blobDataBuffer, 'base64')])), volume: volume }, function (instance) {
            instance.playSound({ sound: 'voiceMailBeep.ogg', volume: volume }, function (instance) {
              instance.startVoiceMailRecording()
            })
          })
        }
      })
    },
    async saveRecordedVoiceMail () {
      const blobData = new Blob(this.chunks, { 'type': 'audio/ogg;codecs=opus' })
      if (blobData.size > 0) {
        const formData = new FormData()
        formData.append('audio-file', blobData)
        formData.append('voicemail_target', this.voicemailTarget)
        formData.append('voicemail_source', this.myPhoneNumber)
        fetch('http://' + this.config.fileUploader.ip + ':3000/recordedMessageUpload', {
          method: 'POST',
          body: formData
        })
      }
    },
    async startVoiceMailRecording () {
      if (this.isRecordingVoiceMail) return
      this.isRecordingVoiceMail = true
      try {
        this.stream = await this.getStream()
        this.prepareRecorder()
      } catch (e) { console.error(e) }
    },
    async stopVoiceMailRecording () {
      this.stopSound()
      this.voicemailMenuIndex = 0
      this.recordedMessagesIndex = 0
      if (this.isRecordingVoiceMail === false) return
      this.mediaRecorder.stop()
      this.mediaRecorder = null
    },
    async getStream () {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true, video: false })
      return stream
    },
    async prepareRecorder () {
      if (this.stream === null) return
      this.mediaRecorder = new MediaRecorder(this.stream)
      this.mediaRecorder.ignoreMutedMedia = true
      this.mediaRecorder.addEventListener('dataavailable', (e) => {
        if (e.data && e.data.size > 0) {
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
      this.mediaRecorder.start()
    }
  },
  watch: {
    appelsInfo () {
      if (this.appelsInfo === null) return
      if (this.appelsInfo.is_accepts === true) {
        this.status = 1
        this.startTimer()
      }
    }
  },
  computed: {
    ...mapGetters(['LangString', 'backgroundURL', 'appelsInfo', 'appelsDisplayName', 'appelsDisplayNumber', 'myPhoneNumber', 'config']),
    timeDisplay () {
      if (this.time < 0) { return this.LangString('APP_PHONE_DIALING_MESSAGE') }
      const min = Math.floor(this.time / 60)
      let sec = this.time % 60
      if (sec < 10) { sec = '0' + sec }
      return `${min}:${sec}`
    }
  },
  mounted () {
    if (this.appelsInfo !== null && this.appelsInfo.initiator === true) {
      this.status = 1
    }
  },
  created () {
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpBackspace', this.onBackspace)

    this.$bus.$on('initVoiceMailListener', this.initVoiceMailListener)
    this.$bus.$on('initVoiceMail', this.initVoiceMail)
    this.$bus.$on('stopVoiceMailRecording', this.stopVoiceMailRecording)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)

    this.$bus.$off('initVoiceMailListener', this.initVoiceMailListener)
    this.$bus.$off('initVoiceMail', this.initVoiceMail)
    this.$bus.$off('stopVoiceMailRecording', this.stopVoiceMailRecording)
    if (this.intervalNum !== undefined) { clearInterval(this.intervalNum) }
  }
}
</script>

<style scoped>
.backblur {
  top: -6px;
  left: -6px;
  right:-6px;
  bottom: -6px;
  position: absolute;
  background-size: cover !important;
  filter: blur(6px);
}

.num {
  position: absolute;
  text-shadow: 0px 0px 15px black, 0px 0px 15px black;
  top: 60px;
  left: 0;
  right: 0;
  color: rgba(255, 255, 255, 0.9);
  text-align: center;
  font-size: 46px;
}

.contactName {
  position: absolute;
  text-shadow: 0px 0px 15px black, 0px 0px 15px black;
  top: 100px;
  left: 0;
  right: 0;
  color: rgba(255, 255, 255, 0.8);
  text-align: center;
  margin-top: 16px;
  font-size: 26px;
}

.time {
  position: relative;
  margin: 0 auto;
  top: 280px;
  left: 0px;
  width: 150px;
  height: 150px;
  border-top: 2px solid white;
  border-radius: 50%;
  animation: rond 1.8s infinite linear;
}

.time-display {
  text-shadow: 0px 0px 15px black, 0px 0px 15px black;
  position: relative;
  top: 187px;
  line-height: 20px;
  left: 0px;
  width: 150px;
  height: 91px;
  color: white;
  font-size: 36px;
  text-align: center;
  margin: 0 auto;
}

.actionbox {
  position: absolute;
  display: flex;
  bottom: 70px;
  left: 0;
  right: 0;
  justify-content: space-around;
}

.action {
  height: 100px;
  width: 100px;
  border-radius: 50%;
}

.hangup {
  text-align: center;
  background-color: #fd3d2e;
  border-radius: 50px;
  height: 80px;
  width: 80px;
}

.hangup i {
  color: #ffffff;
  font-size: 40px;
  padding-bottom: 17px;
  padding-right: 17px;
  transform: rotate(-135deg);
}

.answer {
  text-align: center;
  background-color: #4ddb62;
  border-radius: 50px;
  height: 80px;
  width: 80px;
}

.answer i {
  color: #ffffff;
  font-size: 40px;
  padding-top: 20px;
}

.disableTrue { 
  background-color: #fd3d2e;
  height: 80px;
  width: 80px;
}

.disable { 
  background-color: #4ddb62;
  height: 80px;
  width: 80px;
}

.action svg {
  width: 60px;
  height: 60px;
  margin: 10px;
  fill: #EEE;
}

@keyframes rond {
  from {
    rotate: 0deg
  }
  to {
    rotate: 360deg
  }
}

.extra-content-line {
  width: 70%;
  background-color: white;
  height: 10px;
  border-radius: 20px;
  margin-top: 10px;
  margin-left: auto;
  margin-right: auto;
  box-shadow: 0 2px 5px 2px rgba(0, 0, 0, 0.3);  
}

.keypad-general-container {
  width: 100%;
  height: 86%;
  position: absolute;
  background-color: rgba(95, 95, 95, 0.8);
  bottom: -600px;
  transition: all .4s ease;
  border-radius: 30px;
}

.keypad-general-input {
  position: relative;
  width: 90%;
  height: 50px;
  margin-top: 25px;
  margin-left: auto;
  margin-right: auto;
}

.keypad-general-input input {
  width: 100%;
  height: 100%;
  margin-left: auto;
  margin-right: auto;
  border: none;
  outline: none;
  border-radius: 20px;
  padding-right: 20px;
  font-size: 15px;
  text-align: right;
  box-shadow: 0 2px 5px 2px rgba(0, 0, 0, 0.3);  
}

/* KEYPAD STYLING */

.keyboard {
  display: flex;
  flex-wrap: wrap;
  width: 100%;
}

.key {
  position: relative;
  flex: 1 1 33.33%;
  text-align: center;
  height: 96px;
}

.key-select::after {
  content: '';
  position: absolute;
  top: calc(58% - 45px);
  left: calc(55% - 45px);
  display: block;
  width: 80px;
  height: 80px;
  background: radial-gradient(rgba(255, 255, 255, 0.1), rgba(255, 255, 255, 0.2));
  border-radius: 50%;
}

.key-primary {
  display: block;
  font-size: 36px;
  color: black;
  line-height: 22px;
  padding-top: 34px;
}

.keySpe .key-primary {
  color: #2c3e50;
  line-height: 96px;
  padding: 0;
}

.key-secondary {
  text-transform: uppercase;
  display: block;
  font-size: 12px;
  color: black;
  line-height: 12px;
  padding-top: 8px;
}
</style>
