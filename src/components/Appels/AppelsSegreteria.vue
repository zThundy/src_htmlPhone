<template>
  <div style="display: flex; flex-direction: column;">
    <div style="display: flex; flex-direction: column; width: 100%; height: 300px;">
      <!-- <VueRecordAudio @result="onResult" /> -->
      <div class="toast">
        <custom-toast ref="updating">
          <md-activity-indicator
            :size="20"
            :text-size="16"
            color="white"
            text-color="white"
          >Caricamento...
          </md-activity-indicator>
        </custom-toast>

        <custom-toast ref="success" :content="'Riuscito'" :duration="4000">
          <div style="font-size: 17px; padding-left: 2px;">Riuscito</div>
        </custom-toast>

        <custom-toast ref="error" :content="'Riuscito'" :duration="4000">
          <div style="font-size: 17px; padding-left: 2px;">Errore</div>
        </custom-toast>
      </div>

      <div class="audio-recorder-time">
        <span :style="getTimerColor()">{{ timeDisplay }}/00:15</span>
      </div>

      <div class="audio-recorder-container">
        <div class="audio-recorder-button-container">
          <div class="audio-recorder-button-small" :class="{ select: currentSelect === 0 }">
            <i class="fas fa-stop"></i>
          </div>
        </div>
        <div class="audio-recorder-button-container">
          <div class="audio-recorder-button-big" :class="{ select: currentSelect === 1, recording: !isRecording && !isPaused, paused: isPaused && isRecording }">
            <i v-if="!isRecording && !isPaused" class="fas fa-microphone"></i>
            <i v-else-if="isRecording && !isPaused" style="font-size: 40px; margin-top: 20px;" class="fas fa-pause"></i>
            <i v-else-if="isRecording && isPaused" style="margin-left: 5px; font-size: 40px; margin-top: 20px;" class="fas fa-play"></i>
          </div>
        </div>
        <div class="audio-recorder-button-container">
          <div class="audio-recorder-button-small" :class="{ select: currentSelect === 2 }">
            <i class="fas fa-trash"></i>
          </div>
        </div>
      </div>
      <div class="audio-recorder-container">
        <div class="audio-recorder-button-container">
          <div class="audio-recorder-button-small-listen" :class="{ select: currentSelect === 3 }">
            <i class="fas fa-headphones"></i>
          </div>
        </div>
        <div class="audio-recorder-button-container">
          <div class="audio-recorder-button-small-upload" :class="{ select: currentSelect === 4 }">
            <i class="fas fa-save"></i>
          </div>
        </div>
      </div>
    </div>

    <div>
    </div>
    <audio id="audio-recorded-element" type="audio/ogg"></audio>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

import { Icon, ActivityIndicator } from 'mand-mobile'
import 'mand-mobile/lib/mand-mobile.css'
import CustomToast from '@/components/CustomToast'

const constraints = {
  audio: true,
  video: false
}

export default {
  name: 'calls-segreteria',
  components: {
    CustomToast,
    [Icon.name]: Icon,
    [ActivityIndicator.name]: ActivityIndicator
  },
  data () {
    return {
      currentSelect: -1,
      isRecording: false,
      isPaused: false,
      chunks: [],
      time: -1,
      intervalNum: undefined
    }
  },
  computed: {
    ...mapGetters(['LangString', 'ignoreControls', 'myPhoneNumber', 'config']),
    timeDisplay () {
      if (this.time < 0) { return '00:00' }
      let min = Math.floor(this.time / 60)
      let sec = this.time % 60
      if (sec < 10) { sec = '0' + sec }
      if (min < 10) { min = '0' + min }
      return `${min}:${sec}`
    }
  },
  methods: {
    ...mapActions(['updateIgnoredControls']),
    startTimer () {
      if (this.intervalNum === undefined) {
        this.intervalNum = setInterval(() => {
          this.time += 1
        }, 1000)
      }
    },
    stopTimer (reset) {
      if (this.intervalNum !== undefined) {
        window.clearInterval(this.intervalNum)
        this.intervalNum = undefined
      }
      if (reset) { this.time = 0 }
    },
    getTimerColor () {
      if (this.time > 15) {
        return {
          color: 'red',
          transition: 'all .5s ease'
        }
      } else {
        return {
          color: 'black',
          transition: 'all .5s ease'
        }
      }
    },

    async start () {
      try {
        this.$_stream = await this.getStream()
        this.prepareRecorder()
        this.$_mediaRecorder.start()
        this.startTimer()
      } catch (e) {}
    },
    stop () {
      this.$_mediaRecorder.stop()
      this.$_stream.getTracks().forEach(t => t.stop())
      this.stopTimer(true)
    },
    pause () {
      this.$_mediaRecorder.pause()
      this.stopTimer(false)
    },
    resume () {
      this.$_mediaRecorder.resume()
      this.startTimer()
    },

    async getStream () {
      const stream = await navigator.mediaDevices.getUserMedia(constraints)
      this.$_stream = stream
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
      this.$_mediaRecorder.addEventListener('stop', () => {
        setTimeout(() => {
          const blobData = new Blob(this.chunks, { 'type': 'audio/ogg;codecs=opus' })
          if (blobData.size > 0) {
            const audioElement = document.getElementById('audio-recorded-element')
            audioElement.src = window.URL.createObjectURL(blobData)
            audioElement.play()
            this.isPaused = false
            this.isRecording = false
          }
        })
      }, true)
    },

    saveRecording () {
      this.$refs.updating.show()
      if (this.time > 15) {
        this.$phoneAPI.sendErrorMessage(this.LangString('APP_PHONE_RECORD_TOO_LONG'))
        this.stopTimer(true)
        return
      }
      if (this.myPhoneNumber === undefined || this.myPhoneNumber === null || this.myPhoneNumber === '') {
        this.$phoneAPI.sendErrorMessage(this.LangString('APP_PHONE_NO_SIM_INSTALLED'))
        this.stopTimer(true)
        return
      }
      setTimeout(() => {
        const blobData = new Blob(this.chunks, { 'type': 'audio/ogg;codecs=opus' })
        if (blobData.size > 0) {
          const formData = new FormData()
          formData.append('audio-file', blobData)
          formData.append('filename', this.myPhoneNumber)
          formData.append('type', 'voicemails')
          fetch('http://' + this.config.fileUploader.ip + ':3000/audioUpload', {
            method: 'POST',
            body: formData
          }).then(() => {
            this.$refs.updating.hide()
            this.$refs.success.show()
          }).catch(() => {
            this.$refs.updating.hide()
            this.$refs.error.show()
          })
        } else {
          this.$refs.updating.hide()
          this.$refs.error.show()
        }
        this.chunks = []
      }, 500)
    },

    listenRecording () {
      this.$refs.updating.show()
      if (this.myPhoneNumber === undefined || this.myPhoneNumber === null || this.myPhoneNumber === '') {
        this.$phoneAPI.sendErrorMessage(this.LangString('APP_PHONE_NO_SIM_INSTALLED'))
        this.stopTimer(true)
        return
      }
      setTimeout(() => {
        const blobData = new Blob(this.chunks, { 'type': 'audio/ogg;codecs=opus' })
        if (blobData.size === 0) {
          fetch('http://' + this.config.fileUploader.ip + ':3000/audioDownload?type=voicemails&key=' + this.myPhoneNumber, { method: 'GET' }).then(async resp => {
            if (resp.status === 404) {
              this.$refs.updating.hide()
              this.$refs.error.show()
              return
            }
            const audioElement = document.getElementById('audio-recorded-element')
            audioElement.src = window.URL.createObjectURL(await resp.blob())
            audioElement.play()
            this.$refs.updating.hide()
            this.$refs.success.show()
          }).catch(() => {
            this.$refs.updating.hide()
            this.$refs.error.show()
          })
        } else {
          this.$refs.updating.hide()
          const audioElement = document.getElementById('audio-recorded-element')
          audioElement.src = window.URL.createObjectURL(blobData)
          audioElement.play()
        }
      }, 500)
    },

    // CONTROLS SECTION //

    onEnter () {
      if (this.currentSelect === 0) {
        if (this.isRecording) {
          this.stop()
        }
      }

      if (this.currentSelect === 1) {
        if (!this.isRecording) {
          this.start()
          return
        }

        if (this.isRecording && this.isPaused) {
          this.resume()
        }

        if (this.isRecording && !this.isPaused) {
          this.pause()
        }
      }

      if (this.currentSelect === 2) {
        if (this.time > 15) {
          this.$phoneAPI.sendErrorMessage(this.LangString('APP_PHONE_RECORD_TOO_LONG'))
          this.stopTimer(true)
          return
        }
        if (this.chunks !== []) {
          this.chunks = []
          const audioElement = document.getElementById('audio-recorded-element')
          audioElement.src = ''
          const formData = new FormData()
          formData.append('filename', this.myPhoneNumber)
          formData.append('type', 'voicemails')
          fetch('http://' + this.config.fileUploader.ip + ':3000/audioUpload', {
            method: 'POST',
            body: formData
          }).then(() => {
            this.$refs.updating.hide()
            this.$refs.success.show()
          })
        }
        this.stopTimer(true)
      }
      // this.start()
      // setTimeout(() => {
      //   this.stop()
      // }, 2000)

      if (this.currentSelect === 3) {
        this.listenRecording()
      }

      if (this.currentSelect === 4) {
        this.saveRecording()
      }
    },
    onRight () {
      if (this.currentSelect === 4) return
      this.currentSelect = this.currentSelect + 1
    },
    onDown () {
      if (this.ignoreControls) {
        if (this.currentSelect === 0) {
          this.currentSelect = 3
          return
        }
        if (this.currentSelect > 0 && this.currentSelect < 3) {
          this.currentSelect = 4
          return
        }
        if (this.currentSelect > 1) return
      }
      // select the middle button
      this.currentSelect = 1
      this.updateIgnoredControls(true)
    },
    onLeft () {
      if (this.currentSelect === 0) return
      this.currentSelect = this.currentSelect - 1
    },
    onUp () {
      if (this.currentSelect > 2) {
        if (this.currentSelect === 4) {
          this.currentSelect = 2
          return
        }
        if (this.currentSelect === 3) {
          this.currentSelect = 0
          return
        }
      }
      this.onBackspace()
    },
    onBackspace () {
      if (this.ignoreControls) {
        this.updateIgnoredControls(false)
        this.currentSelect = -1
      }
    }
  },
  mounted () {
    if (!navigator.mediaDevices && !navigator.mediaDevices.getUserMedia) {
      // eslint-disable-next-line
      console.warn('Media Devices are not supported from your browser.')
      return
    }

    this.isSupported = true
  },
  created () {
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpArrowDown', this.onDown)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpArrowDown', this.onDown)
  }
}
</script>

<style scoped>
.audio-recorder-time {
  width: 100%;
  height: 50px;
  text-align-last: center;
}

.audio-recorder-time span {
  position: relative;
  top: 30px;
  font-size: 35px;
  font-weight: bold;
}

.audio-recorder-container {
  display: flex;
  flex-direction: row;

  width: 100%;
  height: 30%;
  text-align-last: center;
}

.audio-recorder-button-container {
  height: 100%;
  width: 100%;
  text-align: -webkit-center;
}

.audio-recorder-button-small {
  position: relative;
  width: 60px;
  height: 60px;
  background-color: rgb(78, 144, 61);
  border-radius: 50%;
  margin-top: 140px;
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.6);
  transition: all .1s ease;
}

.audio-recorder-button-big {
  position: relative;
  width: 80px;
  height: 80px;
  background-color: rgb(78, 144, 61);
  border-radius: 50%;
  margin-top: 100px;
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.6);
  transition: all .1s ease;
}

.audio-recorder-button-small-upload {
  position: relative;
  width: 60px;
  height: 60px;
  background-color: rgb(61, 107, 144);
  border-radius: 50%;
  margin-top: 140px;
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.6);
  transition: all .1s ease;
}

.audio-recorder-button-small-listen {
  position: relative;
  width: 60px;
  height: 60px;
  background-color: rgb(55, 173, 194);
  border-radius: 50%;
  margin-top: 140px;
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.6);
  transition: all .1s ease;
}

i {
  font-size: 25px;
  margin-top: 18px;
  color: rgb(255, 255, 255);
}

.audio-recorder-button-big i {
  font-size: 50px;
  margin-top: 15px;
  color: rgb(255, 255, 255);
}

.select {
  filter: brightness(150%);
}

.recording {
  background-color: rgb(192, 51, 51);
}

.paused {
  background-color: rgb(187, 168, 53);
}

.vue-audio-recorder {
  position: relative;
  background-color: rgb(78, 144, 61);
  border-radius: 50%;
  width: 64px;
  height: 64px;
  display: inline-block;
  cursor: pointer;
  -webkit-box-shadow: 0 0 0 0 rgb(232 76 61 / 70%);
  box-shadow: 0 0 0 0 rgb(232 76 61 / 70%);
}

.toast {
  position: absolute;
  width: 100%;
  height: 62%;
}

</style>
