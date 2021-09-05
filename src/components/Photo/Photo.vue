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

    <div class="picture-snap-cyrcle-contaniner">
      <div class="picture-snap-cyrcle-ext">
        <div v-if="recording" class="picture-snap-cyrcle-int" style="background-color: rgb(255, 40, 40);"></div>
        <div v-else class="picture-snap-cyrcle-int" style="background-color: rgb(190, 190, 190);"></div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
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
      chunks: [],
      videoRequest: null
    }
  },
  computed: {
    ...mapGetters(['LangString'])
  },
  methods: {
    async onEnter () {
      if (this.recording) {
        this.videoRequest.stopRecording()
        this.recording = false
        return
      }
      if (this.ignoreControl) return
      this.ignoreControl = true
      var options = [
        { id: 1, title: this.LangString('APP_PHOTO_TAKE_PICTURE'), icons: 'fa-camera' },
        { id: 2, title: this.LangString('APP_PHOTO_RECORD_VIDEO'), icons: 'fa-video-camera' },
        { id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' }
      ]
      Modal.CreateModal({ scelte: options }).then(resp => {
        switch (resp.id) {
          case 1:
            this.$phoneAPI.takePhoto().then(photo => {
              if (photo) { this.$router.push({ name: 'galleria.splash', params: photo }) }
            })
            break
          case 2:
            this.videoRequest.startVideoRecording()
            this.recording = true
            break
          case -1:
            break
        }
      })
    },
    onBack () {
      if (this.ignoreControls) {
        this.ignoreControls = false
        return
      }
      this.$router.push({ name: 'menu' })
    }
  },
  created () {
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  mounted () {
    this.$phoneAPI.takeVideo().then(() => {
      this.videoRequest = new VideoRequest(document.getElementById('photo-main'), document.getElementById('video-view-element'))
    })
  },
  beforeDestroy () {
    this.videoRequest.stopCapture()
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
#video-view-element {
  /* width: 300px; */
  /* height: 300px; */
  /* background-color: black; */
  /* width: 100%; */
  /* height: 100%; */
  min-width: 100%;
  min-height: 89%;
  width: auto;
  height: auto;
  position: absolute;
  top: 55%;
  left: 50%;
  transform: translate(-50%,-50%);
}

/*
.general-container {
  background-color: black;
  width: 100%;
  height: 100%;
}
*/

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
  /* border: 3px solid black; */
}
</style>
