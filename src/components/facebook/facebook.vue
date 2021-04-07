<template>
  <div class="youtube-container">
  <PhoneTitle :title="LangString('APP_FACEBOOK_TITLE')" :color="'black'" backgroundColor="rgb(255, 180, 89)"/>

    <iframe width="100%" height="315"
      src="https://www.youtube.com/embed/dQw4w9WgXcQ?autoplay=1"
      frameborder="0"
    >
    </iframe>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  computed: {
    ...mapGetters(['LangString'])
  },
  methods: {
    onBack () {
      this.$router.push({ name: 'menu' })
    }
  },
  created () {
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.youtube-container {
  width: 100%;
  height: 100%;
}

iframe {
  margin-top: 60%;
}
</style>
