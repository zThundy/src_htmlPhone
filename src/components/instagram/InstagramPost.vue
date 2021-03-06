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
  watch: {
  },
  methods: {
    ...mapActions(['instagramSaveTempPost']),
    async onEnter () {
      if (this.ignoreControls) return
      this.ignoreControls = true
      // this.$bus.$emit('instagramScegliFiltri')
      // const post = await PhoneAPI.takePhoto()
      // if (post.url !== null) {
      //   this.instagramSaveTempPost(post.url)
      //   this.ignoreControls = false
      //   this.$bus.$emit('instagramScegliFiltri')
      // }
      this.choosePicType()
    },
    async choosePicType () {
      this.ignoreControls = true
      let choix = [
        {id: 1, title: this.LangString('APP_CONFIG_LINK_PICTURE'), icons: 'fa-link'},
        {id: 2, title: this.LangString('APP_CONFIG_TAKE_PICTURE'), icons: 'fa-camera'}
      ]
      const resp = await Modal.CreateModal({ choix: choix })
      if (resp.id === 1) {
        Modal.CreateTextModal({ text: 'https://i.imgur.com/' }).then(valueText => {
          if (valueText.text !== '' && valueText.text !== undefined && valueText.text !== null && valueText.text !== 'https://i.imgur.com/') {
            this.instagramSaveTempPost(valueText.text)
            this.$bus.$emit('instagramScegliFiltri')
            this.ignoreControls = false
          }
        })
      } else if (resp.id === 2) {
        const newAvatar = await this.$phoneAPI.takePhoto()
        if (newAvatar.url !== null) {
          this.instagramSaveTempPost(newAvatar.url)
          this.$bus.$emit('instagramScegliFiltri')
          this.ignoreControls = false
        }
      } else {
        this.ignoreControls = false
      }
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
