<template>
  <div style="width: 330px; height: 743px;" class="phone_app">
    <PhoneTitle :title="currentScreen.title" backgroundColor="#606060" v-on:back="quit"/>
    
    <div class="phone_content">
      <component v-bind:is="currentScreen.component"/>
    </div>

    <div class="darkweb_menu">
      <div v-for="(s, i) in screen" :key="i" class="darkweb_menu-item" :class="{ select: i === currentScreenIndex }">
        <i class="fa" :class="s.icon"></i>
      </div>
    </div>
  </div>
</template>

<script>
import PhoneTitle from './../PhoneTitle'
import DarkwebView from './DarkwebView'
import DarkwebPost from './DarkwebPost'
import { mapGetters } from 'vuex'
// import Vue from 'vue'

export default {
  components: { PhoneTitle },
  data () {
    return {
      currentScreenIndex: 0
    }
  },
  computed: {
    ...mapGetters(['LangString']),
    screen () {
      return [
        {
          title: this.LangString('APP_DARKWEB_TITLE'),
          component: DarkwebView,
          icon: 'fa-home'
        },
        {
          title: this.LangString('APP_DARKWEB_TITLE'),
          component: DarkwebPost,
          icon: ' fa-comment-o'
        }
      ]
    },
    currentScreen () {
      return this.screen[this.currentScreenIndex]
    }
  },
  watch: {
  },
  methods: {
    onLeft () {
      this.currentScreenIndex = Math.max(0, this.currentScreenIndex - 1)
      // Vue.notify({
      //   message: 'messaggio',
      //   title: 'autore' + ' :',
      //   icon: 'twitter',
      //   sound: 'Twitter_Sound_Effect.ogg'
      // })
    },
    onRight () {
      this.currentScreenIndex = Math.min(this.screen.length - 1, this.currentScreenIndex + 1)
      // Vue.notify({
      //   message: 'messaggio',
      //   title: 'autore' + ' :',
      //   icon: 'twitter',
      //   sound: 'Twitter_Sound_Effect.ogg'
      // })
    },
    home () {
      this.currentScreenIndex = 0
    },
    openMenu (index) {
      this.currentScreenIndex = index
    },
    quit () {
      if (this.currentScreenIndex === 0) {
        this.$router.push({ name: 'menu' })
      } else {
        this.currentScreenIndex = 0
      }
    }
  },
  created () {
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('darkwebHome', this.home)
  },
  mounted () {
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('darkwebHome', this.home)
  }
}
</script>

<style scoped>
.darkweb_menu {
  border-top: 1px solid #CCC;
  height: 56px;
  display: flex;
  width: 100%;
}

.darkweb_menu-item {
  flex-grow: 1;
  flex-basis: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  color: #959595;
}

.darkweb_menu-item.select {
  color: #606060;
}

</style>
