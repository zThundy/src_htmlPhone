<template>
  <div class="phone_app">
    <PhoneTitle :title="LangString('APP_GALLERIA_TITLE')" backgroundColor="rgb(217, 122, 81)" :titleColor="'black'" />

    <div class="phone_fullscreen_img" v-if="imgZoom !== undefined">
      <img v-if="imgZoom.type === 'photo'" :src="imgZoom.link" />
      <video v-else-if="imgZoom.type === 'video'" width="330" height="710" id="video-playback-element" autoplay>
        <!-- <source :src="imgZoom.link" type="video/webm" /> -->
        <source type="video/webm" src="https://upload.wikimedia.org/wikipedia/commons/transcoded/1/1d/Alexander_Glazunov_1.webm/Alexander_Glazunov_1.webm.480p.vp9.webm" />
      </video>
    </div>

    <div class="div_immagini">
      <div class='immagini' v-for="(val, key) of fotografie" :key="key + 1" :style="{ src: 'url(' + val.link +')' }">
        <img v-if="val.type === 'photo'" class="immagine" :src="val.link" :class="{ select: key + 1 === currentSelect }" />
        <div v-else-if="val.type === 'video'" class="video-container" :class="{ select: key + 1 === currentSelect }">
          <i class="fas fa-play"></i>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
import PhoneTitle from '@/components/PhoneTitle'
import { mapGetters, mapActions, mapMutations } from 'vuex'
import Modal from '@/components/Modal/index.js'

export default {
  name: 'galleria',
  components: { PhoneTitle },
  data () {
    return {
      currentSelect: 1,
      ignoredControls: false,
      imgZoom: undefined
    }
  },
  computed: {
    ...mapGetters(['LangString', 'fotografie', 'bluetooth', 'config'])
  },
  methods: {
    ...mapActions(['setBackground', 'clearGallery', 'deleteSinglePicture']),
    ...mapMutations(['CHANGE_BRIGHTNESS_STATE']),
    scrollIntoView: function () {
      this.$nextTick(() => {
        var elem = this.$el.querySelector('.select')
        if (elem === undefined || elem === null) return
        elem.scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' })
      })
    },
    onUp () {
      if (this.ignoredControls) return
      if (this.currentSelect === 1 || this.currentSelect === 2) return
      this.currentSelect = this.currentSelect - 2
      this.scrollIntoView()
    },
    onDown () {
      if (this.ignoredControls) return
      if (this.currentSelect === this.fotografie.length || this.currentSelect === this.fotografie.length - 1) return
      this.currentSelect = this.currentSelect + 2
      this.scrollIntoView()
    },
    onLeft () {
      if (this.ignoredControls) return
      if (this.currentSelect === 1) return
      this.currentSelect = this.currentSelect - 1
      this.scrollIntoView()
    },
    onRight () {
      if (this.ignoredControls) return
      if (this.currentSelect === this.fotografie.length) return
      this.currentSelect = this.currentSelect + 1
      this.scrollIntoView()
    },
    onBackspace () {
      if (this.imgZoom) {
        this.imgZoom = undefined
        this.CHANGE_BRIGHTNESS_STATE(true)
        return
      }
      if (this.ignoredControls) return
      this.$router.push({ name: 'menu' })
    },
    getSMSVideoInfo (mess) {
      var obj = mess.split('%')
      return {
        id: obj[2],
        number: obj[1]
      }
    },
    async onEnter () {
      if (this.imgZoom) {
        if (this.imgZoom.type === 'video' && this.videoElement) {
          this.videoElement.currentTime = 0
          this.videoElement.play()
        }
        return
      }
      if (this.fotografie.length === 0) return
      if (this.ignoredControls) return
      var element = this.fotografie[this.currentSelect - 1]
      this.ignoredControls = true
      try {
        let scelte = []
        if (element.type === 'photo') {
          scelte = [
            { id: 0, title: this.LangString('APP_GALLERIA_ZOOM'), icons: 'fa-search' },
            { id: 1, title: this.LangString('APP_GALLERIA_SET_WALLPAPER'), icons: 'fa-mobile' }
          ]
        } else if (element.type === 'video') {
          scelte = [
            { id: 0, title: this.LangString('APP_GALLERIA_ZOOM_VIDEO'), icons: 'fa-search' }
          ]
        }
        scelte = [
          ...scelte,
          { id: 2, title: this.LangString('APP_GALLERIA_INOLTRA'), icons: 'fa-paper-plane' },
          { id: 4, title: this.LangString('APP_GALLERIA_SEND_BLUETOOTH'), icons: 'fa-share-square' },
          { id: 5, title: this.LangString('APP_GALLERIA_ELIMINA'), icons: 'fa-trash', color: 'orange' },
          { id: 3, title: this.LangString('APP_GALLERIA_ELIMINA_TUTTO'), icons: 'fa-trash', color: 'red' },
          { id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' }
        ]
        const data = await Modal.CreateModal({ scelte })
        switch (data.id) {
          case 0:
            if (element.type === 'video') {
              const videoData = this.getSMSVideoInfo(element.link)
              fetch('http://' + this.config.fileUploader.ip + ':' + this.config.fileUploader.port + '/videoDownload?type=camera&key=' + videoData.id, {
                method: 'GET'
              }).then(async resp => {
                if (resp.status === 404) {
                  this.$phoneAPI.ongenericNotification({
                    message: 'VIDEO_NOT_FOUND',
                    title: 'VIDEO_ERROR_TITLE',
                    icon: 'camera',
                    backgroundColor: 'rgb(205, 116, 76)',
                    appName: 'Galleria'
                  })
                  return console.err('404 error')
                }
                this.imgZoom = Object.assign({}, element)
                var jsonResponse = await resp.json()
                this.imgZoom.link = window.URL.createObjectURL(new Blob([Buffer.from(jsonResponse.blobDataBuffer, 'base64')]))
                this.videoElement = document.getElementById('video-playback-element')
              }).catch(() => {})
            } else if (element.type === 'photo') {
              this.imgZoom = element
            }
            this.CHANGE_BRIGHTNESS_STATE(false)
            break
          case 1:
            this.setBackground({ label: 'Personalizzato', value: element.link })
            this.ignoredControls = false
            break
          case 2:
            this.$router.push({ name: 'messages.chooseinoltra', params: { message: element.link } })
            this.ignoredControls = false
            break
          case 3:
            this.clearGallery()
            this.ignoredControls = false
            break
          case 4:
            if (this.bluetooth) {
              try {
                this.ignoredControls = true
                let scelte = []
                var cancel = { id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' }
                this.$phoneAPI.getClosestPlayers().then(async closestPlayers => {
                  console.log(JSON.stringify(closestPlayers))
                  for (var i in closestPlayers) { scelte.push({ id: closestPlayers[i].id, label: closestPlayers[i].name, title: closestPlayers[i].name, icons: 'fa-share-square' }) }
                  scelte.push(cancel)
                  const data = await Modal.CreateModal({ scelte })
                  if (data.id === -1) {
                    this.ignoredControls = false
                  } else {
                    this.ignoredControls = false
                    this.$phoneAPI.sendPicToUser({ id: data.id, message: element.link })
                  }
                })
              } catch (e) { } finally { this.ignoredControls = false }
            } else {
              this.$phoneAPI.sendErrorMessage('Il bluetooth è disattivo')
              this.ignoredControls = false
            }
            break
          case 5:
            this.deleteSinglePicture(this.currentSelect)
            break
        }
      } catch (e) { } finally { this.ignoredControls = false }
    }
  },

  created () {
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
    this.$bus.$on('keyUpEnter', this.onEnter)
  },

  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpEnter', this.onEnter)
  }
}
</script>

<style scoped>
.div_immagini {
  position: relative;
  width: 100%;
  height: 650px;
  padding: 7px 8px;
  display: flex;
  flex-wrap: wrap;
  align-content: flex-start;
  overflow-y: scroll;

  background-color: white;
}

.immagini {
  margin-bottom: 2px;
  width: 98%;
  height: 85px;
  flex: 0 50%;
}

.immagine {
  width: inherit;
  height: inherit;
}

.immagine.select {
  border: 3px solid rgb(205, 116, 76);
  filter: brightness(90%)
}

.video-container {
  background-color: black;
  width: inherit;
  height: inherit;
  text-align: center;
  padding-top: 20%;
}

.video-container i {
  color: white;
}

.video-container.select {
  border: 3px solid rgb(205, 116, 76);
  filter: brightness(90%)
}
</style>
