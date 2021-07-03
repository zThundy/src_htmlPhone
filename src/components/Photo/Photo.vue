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

// import aperture from 'aperture'
// const RECORD_OPTIONS = {
//   fps: 15,
//   cropArea: {
//     x: 100,
//     y: 100,
//     width: 500,
//     height: 500
//   }
// }

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
    async onEnter () {
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
  top: 520px;
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

  bottom: 14px;
  left: 125px;

  height: 80px;
  width: 80px;
  background-color: white;
  border-radius: 50px;

  border: 3px solid black;
}
</style>
