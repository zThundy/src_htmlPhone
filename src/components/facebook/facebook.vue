<template>
  <div class="youtube-container">
  <PhoneTitle :title="LangString('APP_FACEBOOK_TITLE')" :color="'black'" backgroundColor="rgb(0, 150, 223)"/>

    <div v-if="isShowing">
      <iframe width="100%" height="315"
        src="https://www.youtube.com/embed/dQw4w9WgXcQ?autoplay=1"
        frameborder="0"
      >
      </iframe>
    </div>
    <div v-else>
      <div class="warning-text-container">
        <i class="fa fa-warning"></i>
        <span style="color: red;">ATTENZIONE</span>
        <span>Se sei streamer non continuare, altrimenti premi invio!</span>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import PhoneTitle from '@/components/PhoneTitle'

export default {
  components: {
    PhoneTitle
  },
  data () {
    return {
      isShowing: false
    }
  },
  computed: {
    ...mapGetters(['LangString'])
  },
  methods: {
    onBack () {
      this.$router.push({ name: 'menu' })
    },
    onEnter () {
      this.isShowing = true
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
.youtube-container {
  width: 100%;
  height: 100%;
}

iframe {
  margin-top: 45%;
}

.warning-text-container {
  width: 100%;
  height: 650px;
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.warning-text-container i {
  margin-top: 50px;
  font-size: 90px;
  color: orange;
}

.warning-text-container span {
  margin-top: 50px;
  font-size: 40px;
  width: 80%;
  color: black;
  font-weight: bold;
}
</style>
