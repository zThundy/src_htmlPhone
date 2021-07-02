<template>
  <div style="width: 326px; height: 743px;">
    <!-- <VueRecordAudio @result="onResult" /> -->
    <div class="audio-recorder-container">
      <audio id="audio-recorded-element" type="audio/ogg"></audio>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

const constraints = {
  audio: true,
  video: false
}

export default {
  name: 'calls-segreteria',
  components: { },
  data () {
    return {
      isSupported: false,
      hasPermission: false,
      isRecording: false,
      isPaused: false,
      chunks: []
    }
  },
  methods: {
    ...mapActions([]),
    async start () {
      if (this.isRecording) { return }

      try {
        this.$_stream = await this.getStream()
        this.prepareRecorder()
        this.$_mediaRecorder.start()
      } catch (e) {
        // this.$emit('error', e)
        // eslint-disable-next-line
        console.error(e)
      }
    },
    stop () {
      if (!this.isRecording) return
      this.$_mediaRecorder.stop()
      this.$_stream.getTracks().forEach(t => t.stop())
    },
    pause () {
      if (!this.isRecording) return
      this.$_mediaRecorder.pause()
    },
    resume () {
      if (!this.isPaused) return
      this.$_mediaRecorder.resume()
    },

    async getStream () {
      const stream = await navigator.mediaDevices.getUserMedia(constraints)
      this.$_stream = stream
      // this.$emit('stream', stream)
      return stream
    },

    prepareRecorder () {
      if (!this.$_stream) { return }

      this.$_mediaRecorder = new MediaRecorder(this.$_stream)
      this.$_mediaRecorder.ignoreMutedMedia = true

      this.$_mediaRecorder.addEventListener('start', () => {
        this.isRecording = true
        this.isPaused = false
        // this.$emit('start')
      })

      this.$_mediaRecorder.addEventListener('resume', () => {
        this.isRecording = true
        this.isPaused = false
        // this.$emit('resume')
      })

      this.$_mediaRecorder.addEventListener('pause', () => {
        this.isPaused = true
        // this.$emit('pause')
      })

      this.$_mediaRecorder.addEventListener('dataavailable', (e) => {
        if (e.data && e.data.size > 0) {
          // console.log(e.data)
          this.chunks.push(e.data)
        }
      }, true)

      this.$_mediaRecorder.addEventListener('stop', () => {
        // this.$emit('stop')
        setTimeout(() => {
          const blobData = new Blob(this.chunks, { 'type': 'audio/ogg;codecs=opus' })
          if (blobData.size > 0) {
            // this.$emit('result', blobData)
            console.log(blobData)
            const audioElement = document.getElementById('audio-recorded-element')
            console.log(blobData.duration)
            console.log(window.URL.createObjectURL(blobData))
            audioElement.src = window.URL.createObjectURL(blobData)
            // audioElement.onloadedmetadata = function () {
            //   console.log('audioElement.currentTime', audioElement.currentTime)
            //   console.log('before audioduration', audioElement.duration)
            //   if (audioElement.duration === Infinity) {
            //     console.log('passed')
            //     audioElement.currentTime = 1e101
            //     audioElement.ontimeupdate = function () {
            //       console.log('ontimeupdate 1')
            //       this.ontimeupdate = () => {
            //         console.log('ontimeupdate 2')
            //         return
            //       }
            //       audioElement.currentTime = 0
            //       console.log('audioElement.currentTime', audioElement.currentTime)
            //       console.log('after audioduration', audioElement.duration)
            //       return
            //     }
            //   }
            // }

            audioElement.play()

            // blobData.slice(0, blobData.size)
            const formData = new FormData()
            formData.append('audio-file', blobData)
            formData.append('filename', '11000011526dc19')
            fetch('http://localhost:3000/audioUpload', {
              method: 'POST',
              body: formData
            })
          }
          this.chunks = []
          this.isPaused = false
          this.isRecording = false
        }, 500)
      }, true)
    },
    onEnter () {
      console.log('start record')
      this.start()
      setTimeout(() => {
        console.log('stop record')
        this.stop()
      }, 2000)
    },
    onRight () {
      fetch('http://localhost:3000/audioDownload?key=11000011526dc19', {
        method: 'GET'
      }).then(async resp => {
        // console.log(resp.status)
        if (resp.status === 404) {
          return
        }
        // console.log(await resp.text())
        // retrieve the JSON string somehow
        // console.log(await resp.blob())
        // const json = await resp.text()
        // const parsed = JSON.parse(json)
        // // retrieve the original buffer of data
        // var buff = Buffer.from(parsed.blob, 'base64')
        // console.log(buff)
        // const blobData = /* new Blob(await resp.blob(), { 'type': 'audio/ogg;codecs=opus' }) */ await resp.blob()
        // console.log(blobData)
        const audioElement = document.getElementById('audio-recorded-element')
        // console.log(window.URL.createObjectURL(blobData))
        audioElement.src = window.URL.createObjectURL(await resp.blob())
        audioElement.play()
        // audioElement.onloadedmetadata = function () {
        //   console.log('loadedmeta')
        //   audioElement.play()
        // }
      })
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
  computed: {
    ...mapGetters(['LangString'])
  },
  created () {
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpArrowRight', this.onRight)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpArrowRight', this.onRight)
  }
}
</script>

<style scoped>
.audio-recorder-container {
  width: 100%;
  height: 150px;
  text-align-last: center;
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

/* #audio-recorded-element {} */
</style>
