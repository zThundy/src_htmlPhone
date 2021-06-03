<template>
  <div style="width: 100%; height: 100%;" class="phone_app">
    <PhoneTitle class="decor-border" :backgroundColor="'white'" :title="LangString('APP_PHOTO_TITLE')" />

    <div class="general-container">
      <div class="picture-snap-cyrcle-contaniner">
        <div class="picture-snap-cyrcle-ext"></div>
        <div class="picture-snap-cyrcle-int"></div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import PhoneTitle from './../PhoneTitle'
import Modal from '@/components/Modal/index'

// import recordScreen from 'record-screen'

export default {
  name: 'photo',
  components: { PhoneTitle },
  data () {
    return {
      ignoreControls: false,
      recording: null
    }
  },
  computed: {
    ...mapGetters(['LangString'])
  },
  methods: {
    // ...mapActions(['addPhoto'])
    async onEnter () {
      if (this.ignoreControl) return
      this.ignoreControl = true
      var options = [
        { id: 1, title: this.LangString('APP_PHOTO_TAKE_PICTURE'), icons: 'fa-camera' },
        // { id: 2, title: this.LangString('APP_PHOTO_RECORD_VIDEO'), icons: 'fa-video-camera' },
        { id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' }
      ]
      Modal.CreateModal({ choix: options }).then(async resp => {
        switch (resp.id) {
          case 1:
            const resp = await this.$phoneAPI.takePhoto()
            // this.addPhoto({ link: resp.url })
            if (resp) {
              this.$router.push({ name: 'galleria.splash', params: resp })
            }
            break
          case 2:
            // if (this.recording) return
            // this.recording = recordScreen('/tmp/video.mp4', { resolution: '1280x720' })
            // this.recording.promise.then(result => {
            //   process.stdout.write(result.stdout)
            //   process.stderr.write(result.stderr)
            // }).catch(error => { console.error(error) })
            // setTimeout(() => this.recording.stop(), 5000)
            break
          case -1:
            this.ignoreControl = false
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
  async created () {
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.general-container {
  background-color: black;
  width: 100%;
  height: 100%;
}

.picture-snap-cyrcle-contaniner {
  position: relative;
  top: 495px;
  width: 100%;
  height: 15%;
}

.picture-snap-cyrcle-ext {
  margin-left: auto;
  margin-right: auto;

  height: 90px;
  width: 90px;
  background-color: white;
  border-radius: 50px;
}

.picture-snap-cyrcle-int {
  position: absolute;

  bottom: 5px;
  left: 125px;

  height: 80px;
  width: 80px;
  background-color: white;
  border-radius: 50px;

  border: 3px solid black;
}
</style>
