<template>
  <div style="width: 326px; height: 743px;" class="phone_content">

    <div class='resize_immagine'>
      <i class="fa fa-camera-retro fa-5x" style="color: #E533FF;"></i>
    </div>

    <span class='instagram_send'>{{ IntlString('APP_INSTAGRAM_POST_PICTURE') }}</span> 
  </div>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'
import PhoneAPI from './../../PhoneAPI'

export default {
  components: {},
  data () {
    return {
      message: '',
      ignoreControls: false
    }
  },
  computed: {
    ...mapGetters(['IntlString'])
  },
  watch: {
  },
  methods: {
    ...mapActions(['instagramSaveTempPost']),
    async onEnter () {
      if (this.ignoreControls) return
      this.ignoreControls = true
      // this.$bus.$emit('instagramScegliFiltri')
      const post = await PhoneAPI.takePhoto()
      if (post.url !== null) {
        this.instagramSaveTempPost(post.url)
        this.ignoreControls = false
        this.$bus.$emit('instagramScegliFiltri')
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
.phone_content {
  background: #f4dbe7;
}

.resize_immagine {
  top: 200px;
  left: 115px;
  font-size: 20px;
  position: absolute;
  align-content: center;
}

.instagram_send {
  position: absolute;
  top: 320px;
  right: 0px;
  left: 85px;
  width: 120px;
  height: 32px;
  border-radius: 16px;
  background-color: rgba(242, 29, 231, 0.61);

  margin-bottom: 2px;
  color: white;

  line-height: 32px;
  text-align: center;
  margin: 26px 20px;
  font-size: 16px;
}
</style>
