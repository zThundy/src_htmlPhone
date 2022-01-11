<template>
  <div id="photo-main" style="width: 100%; height: 100%;" class="phone_app">
    <InfoBare />
    <video id="video-view-element" crossorigin="anonymous" autoplay></video>
  </div>
</template>

<script>
import InfoBare from '@/components/InfoBare'

export default {
  name: 'videocalls-active',
  components: { InfoBare },
  data () {
    return {
      ignoreControls: false
    }
  },
  computed: {},
  methods: {
    onBack () {
      if (this.ignoreControls) return
      this.$router.push({ name: 'menu' })
    }
  },
  created () {
    this.$bus.$on('keyUpBackspace', this.onBack)
    this.contact = this.$route.params.contact

    this.$phoneAPI.openFakeCamera(true).then(() => {
      this.videoElement = document.getElementById('video-view-element')
      this.$phoneAPI.videoRequest.initRenderer(document.getElementById('photo-main'), this.videoElement)
      this.$phoneAPI.startVideoCall({ number: this.contact.number, stream: this.$phoneAPI.videoRequest.getVideoStream() })
    })
  },
  beforeDestroy () {
    this.$phoneAPI.post('setEnabledFakeCamera', false)
    this.$phoneAPI.videoRequest.clearRenderer()

    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
</style>
