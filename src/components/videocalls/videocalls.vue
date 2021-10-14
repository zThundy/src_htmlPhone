<template>
  <div class="phone_app">
    <PhoneTitle :title="LangString('APP_VIDEOCALLS_TITLE')" :color="'white'" :backgroundColor="'rgb(70, 0, 115)'" />

    <div class="videocalls-dot">
      <i class="fa fa-video"></i>
    </div>
  </div>
</template>

<script>
import PhoneTitle from './../PhoneTitle'
import { mapGetters } from 'vuex'

export default {
  name: 'videocalls',
  components: { PhoneTitle },
  data () {
    return {}
  },
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
.videocalls-dot {
  position: fixed;
  width: 60px;
  height: 60px;
  background-color: rgb(70, 0, 115);
  bottom: 21%;
  right: 31%;
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.6);
  border-radius: 50%;
}

.videocalls-dot i {
  color: white;
  padding-top: 16px;
  font-size: 28px;
  display: flex;
  justify-content: center;
}
</style>
