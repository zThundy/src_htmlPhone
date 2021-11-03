<template>
  <div class="general-container">
    <div class="picture-snap-cyrcle-contaniner">
      <div class="picture-snap-cyrcle-ext"></div>
      <div class="picture-snap-cyrcle-int"></div>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'
import Modal from '@/components/Modal/index.js'

export default {
  components: {},
  data () {
    return {
      message: '',
      ignoreControls: false
    }
  },
  computed: {
    ...mapGetters(['LangString'])
  },
  // watch: { },
  methods: {
    ...mapActions(['instagramSaveTempPost']),
    async onEnter () {
      if (this.ignoreControls) return
      this.ignoreControls = true
      this.choosePicType()
    },
    async choosePicType () {
      this.ignoreControls = true
      Modal.CreateModal({ scelte: [
        { id: 1, title: this.LangString('APP_CONFIG_LINK_PICTURE'), icons: 'fa-link' },
        { id: 2, title: this.LangString('APP_CONFIG_TAKE_PICTURE'), icons: 'fa-camera' }
      ] }).then(async resp => {
        switch(resp.id) {
          case 1:
            Modal.CreateTextModal({
              text: 'https://i.imgur.com/',
              title: this.LangString('TYPE_LINK')
            })
            .then(resp => {
              if (resp.text !== '' && resp.text !== undefined && resp.text !== null && resp.text !== 'https://i.imgur.com/') {
                this.instagramSaveTempPost(resp.text)
                this.$bus.$emit('instagramScegliFiltri')
                this.ignoreControls = false
              }
            })
            .catch(e => { this.ignoreControls = false })
            break
          case 2:
            const pic = await this.$phoneAPI.takePhoto()
            if (pic && pic !== '') {
              this.instagramSaveTempPost(pic)
              this.$bus.$emit('instagramScegliFiltri')
              this.ignoreControls = false
            }
            break
        }
      })
      .catch(e => { this.ignoreControls = false })
    },
    onBack () {
      if (this.ignoreControls) {
        this.ignoreControls = false
      } else {
        this.$bus.$emit('instagramHome')
      }
    }
  },
  created () {
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
