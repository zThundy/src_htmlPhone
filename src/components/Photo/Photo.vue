<template>
  <div id="photo-main" style="width: 100%; height: 100%;" class="phone_app">
    <InfoBare />
    <!--
    <div class="general-container">
      <div class="picture-snap-cyrcle-contaniner">
        <div class="picture-snap-cyrcle-ext"></div>
        <div class="picture-snap-cyrcle-int"></div>
      </div>
    </div>
    -->

    <video id="video-view-element" crossorigin="anonymous" autoplay></video>

    <div class="save-panel-container" :style="showSavePanel ? { 'opacity': '1', 'top': '35%' } : { 'opacity': '0', 'top': '20%' }">
      <div class="save-panel-bg">
        <div class="save-panel-title-container">
          <span>{{ LangString("APP_PHOTO_SAVE_VIDEO_TITLE") }}</span>
        </div>

        <div class="save-panel-buttons-container">
          <div style="width: 100%">
            <div style="background-color: rgb(200, 30, 30);" class="save-panel-button" :class="{ select: currentSelect === 0 }">
              <span>{{ LangString("CANCEL") }}</span>
            </div>
          </div>

          <div style="width: 100%">
            <div style="background-color: rgb(30, 200, 30);" class="save-panel-button" :class="{ select: currentSelect === 1 }">
              <span>{{ LangString("CONFIRM") }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="picture-snap-cyrcle-contaniner">
      <div class="picture-snap-cyrcle-ext">
        <div v-if="recording" class="picture-snap-cyrcle-int" style="background-color: rgb(255, 40, 40);"></div>
        <div v-else class="picture-snap-cyrcle-int" style="background-color: rgb(190, 190, 190);"></div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'
import InfoBare from '@/components/InfoBare'
import Modal from '@/components/Modal/index'

import VideoRequest from '@/VideoRequest'

export default {
  name: 'photo',
  components: { InfoBare },
  data () {
    return {
      ignoreControls: false,
      recording: false,
      currentBlob: [],
      videoElement: null,
      videoRequest: null,
      frontCamera: null,
      showSavePanel: false,
      currentSelect: 0
    }
  },
  computed: {
    ...mapGetters(['LangString', 'config', 'myPhoneNumber'])
  },
  methods: {
    ...mapActions(['addPhoto']),
    async onEnter () {
      if (this.showSavePanel) {
        if (this.currentSelect === 1) {
          if (this.videoElement.src && this.videoElement.src !== '') {
            // saving shit
            // console.log(this.currentBlob.size)
            // console.log(this.currentBlob)
            const id = this.$phoneAPI.makeid(20, true)
            const formData = new FormData()
            formData.append('video-file', this.currentBlob)
            formData.append('filename', id)
            formData.append('type', 'camera')
            fetch('http://' + this.config.fileUploader.ip + ':' + this.config.fileUploader.port + '/videoUpload', {
              method: 'POST',
              body: formData
            }).then(() => {
              const videoFormat = '[VIDEO]%' + this.myPhoneNumber + '%' + id
              this.addPhoto({ link: videoFormat, type: 'video' })
              this.$router.push({ name: 'galleria.splash' })
            }).catch((error) => { console.error(error) })
            this.showSavePanel = false
          }
        } else if (this.currentSelect === 0) {
          this.showSavePanel = false
          setTimeout(() => {
            this.showSavePanel = true
          }, 2000)
        }
        return
      }
      if (this.recording) {
        this.videoRequest.stopRecording()
        this.recording = false
        return
      }
      if (this.ignoreControls) return
      this.ignoreControls = true
      var options = [
        { id: 1, title: this.LangString('APP_PHOTO_TAKE_PICTURE'), icons: 'fa-camera' },
        { id: 2, title: this.LangString('APP_PHOTO_RECORD_VIDEO'), icons: 'fa-video-camera' },
        { id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' }
      ]
      Modal.CreateModal({ scelte: options }).then(async resp => {
        switch (resp.id) {
          case 1:
            const pic = await this.$phoneAPI.takePhoto()
            this.ignoreControls = false
            if (pic && pic !== '') { this.$router.push({ name: 'galleria.splash' }) }
            break
          case 2:
            this.videoRequest.startVideoRecording((blob) => {
              if (blob.size > 0) {
                this.showSavePanel = true
                this.currentBlob = blob
              }
            })
            this.recording = true
            this.ignoreControls = false
            break
          case -1:
            this.ignoreControls = false
            break
        }
      })
    },
    onUp () {
      if (this.videoRequest) {
        if (this.frontCamera) {
          this.videoRequest.setXModifier(this.frontCamera)
          this.frontCamera = null
        } else {
          this.frontCamera = this.videoRequest.getXModifier()
          this.videoRequest.setXModifier(this.frontCamera + 100)
        }
      }
    },
    onLeft () {
      if (this.showSavePanel) {
        this.currentSelect = 0
        return
      }
      this.frontCamera = this.videoRequest.getXModifier()
      this.videoRequest.setXModifier(this.frontCamera + 50)
    },
    onRight () {
      if (this.showSavePanel) {
        this.currentSelect = 1
        return
      }
      this.frontCamera = this.videoRequest.getXModifier()
      this.videoRequest.setXModifier(this.frontCamera - 50)
    },
    onBack () {
      if (this.ignoreControls) {
        this.ignoreControls = false
        return
      }
      if (this.showSavePanel) {
        this.currentSelect = 0
        this.showSavePanel = false
        return
      }
      this.$router.push({ name: 'menu' })
    }
  },
  created () {
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)

    this.$phoneAPI.openFakeCamera().then(() => {
      this.videoElement = document.getElementById('video-view-element')
      this.videoRequest = new VideoRequest(document.getElementById('photo-main'), this.videoElement)
      this.videoElement.onended = () => {
        this.showSavePanel = true
      }
    })
  },
  // mounted () {
  // },
  beforeDestroy () {
    if (this.videoRequest) this.videoRequest.stopCapture()
    this.videoRequest = null
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
  }
}
</script>

<style scoped>
#video-view-element {
  display: block;
  width: 330px;
  height: 710px;
  top: 27px;
  position: absolute;
  z-index: 0;
}

.picture-snap-cyrcle-contaniner {
  position: relative;
  top: 600px;
  width: 100%;
  height: 15%;
  z-index: 1;
}

.picture-snap-cyrcle-ext {
  position: absolute;
  bottom: 14px;
  left: 125px;
  height: 80px;
  width: 80px;
  background-color: white;
  border-radius: 50px;
  border: 3px solid black;
}

.picture-snap-cyrcle-int {
  position: absolute;
  bottom: 2px;
  left: 2px;
  height: 70px;
  width: 70px;
  border-radius: 50px;
  transition: all ease .5s;
}

.save-panel-container {
  width: 100%;
  height: 150px;
  position: absolute;
  top: 35%;
  transition: all .4s ease-in-out;
  z-index: 1;
}

.save-panel-bg {
  position: relative;
  margin-left: auto;
  margin-right: auto;
  width: 90%;
  height: 120px;
  border-radius: 20px;
  background-color: white;
}

.save-panel-title-container {
  width: 100%;
  height: 50%;
  text-align: center;
  padding-top: 15px;
}

.save-panel-title-container span {
  font-weight: bold;
    font-size: 18px;
}

.save-panel-buttons-container {
  width: 100%;
  height: 50%;
  text-align: center;
  padding-top: 20px;
  display: flex;
  flex-direction: row;
}

.save-panel-button {
  width: 70%;
  margin-left: auto;
  margin-right: auto;
  position: relative;
  height: 25px;
  border-radius: 10px;
}

.save-panel-button.select {
  filter: brightness(1.3)
}
</style>
