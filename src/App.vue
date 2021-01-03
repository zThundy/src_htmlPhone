<template>
  <div style="height: 100vh; width: 100vw;">
    <notification />
    <div v-if="show === true && tempoHide === false" :style="{ zoom: zoom }">
      <div :style="getStyle(brightness)" class="phone_wrapper">
        <div v-if="currentCover" class="phone_coque" :style="{ backgroundImage: 'url(/html/static/img/cover/' + currentCover.value + ')' }"></div>
        
          <div id="app" class="phone_screen noselect">
            <!-- <transition-page :isChanging="isChanging"/> :class="{ 'transition': isChanging }" -->
            <router-view />
          </div>

      </div>
    </div>

  </div>
</template>

<script>

import './PhoneBaseStyle.scss'

import './assets/css/font-awesome.min.css'
// import './assets/css/fontawesome.min.css'

import { mapGetters, mapActions } from 'vuex'
import { Howl } from 'howler'
import TransitionPage from './components/TransitionPage'
import PhoneAPI from './PhoneAPI.js'

export default {
  name: 'app',
  components: { TransitionPage },
  data () {
    return {
      soundCall: null,
      isChanging: false,
      currentRoute: window.location.pathname
    }
  },
  methods: {
    ...mapActions(['loadConfig', 'rejectCall']),
    closePhone () {
      this.$phoneAPI.closePhone()
    },
    getStyle (val) {
      return {
        'filter': 'brightness(' + ((val / 100) + 0.10) + ')'
      }
    }
  },
  computed: {
    ...mapGetters(['show', 'zoom', 'currentCover', 'sonido', 'appelsInfo', 'myPhoneNumber', 'volume', 'tempoHide', 'brightness'])
  },
  watch: {
    appelsInfo (newValue, oldValue) {
      if (this.appelsInfo !== null && this.appelsInfo.is_accepts !== true) {
        if (this.soundCall !== null) {
          this.soundCall.pause()
        }
        var path = null
        if (this.appelsInfo.initiator === true) {
          path = '/html/static/sound/Phone_Call_Sound_Effect.ogg'
          this.soundCall = new Howl({ src: path, loop: true })
        } else {
          path = '/html/static/sound/' + this.sonido.value
          this.soundCall = new Howl({
            src: path,
            onend: function () {
              PhoneAPI.endSuoneriaForOthers()
            },
            onplay: function () {
              PhoneAPI.startSuoneriaForOthers(this.sonido.value)
            }
          })
        }
        this.soundCall.loop = true
        this.soundCall.volume = this.volume
        this.soundCall.play()
      } else if (this.soundCall !== null) {
        this.soundCall.pause()
        this.soundCall = null
      }
      if (newValue === null && oldValue !== null) {
        this.$router.push({ name: 'lockscreen' })
        return
      }
      if (newValue !== null) {
        this.$router.push({ name: 'appels.active' })
      }
    },
    show () {
      if (this.appelsInfo !== null) {
        this.$router.push({ name: 'appels.active' })
      } else {
        this.$router.push({ name: 'lockscreen' })
      }
      if (this.show === false && this.appelsInfo !== null) {
        this.rejectCall()
      }
    }
  },
  mounted () {
    this.loadConfig()
    window.addEventListener('message', (event) => {
      if (event.data.keyUp !== undefined) {
        this.$bus.$emit('keyUp' + event.data.keyUp)
      }
    })
    window.addEventListener('keyup', (event) => {
      const keyValid = ['ArrowRight', 'ArrowLeft', 'ArrowUp', 'ArrowDown', 'Backspace', 'Enter']
      if (keyValid.indexOf(event.key) !== -1) {
        this.$bus.$emit('keyUp' + event.key)
        if (event.key === 'Backspace') { }
      }
      if (event.key === 'Escape') {
        this.$phoneAPI.closePhone()
      }
    })
  },
  created () {
    this.$router.push({ name: 'lockscreen' })

    this.$router.beforeEach((to, from, next) => {
      if ((to.meta !== undefined && to.meta !== null) && (from.meta !== undefined && from.meta !== null)) {
        // se stai arrivando da un router che si trova più in alto
        // (indice maggiore) di quello a cui stai andando, fai l'animazione
        if (to.meta.depth > from.meta.depth) {
          this.isChanging = true
        }
        // if (from.meta.depth > to.meta.depth) {
        //   this.index = from.meta.depth
        // }
      }
      setTimeout(() => {
        this.isChanging = false
      }, 500)
      next()
    })
  }
}
</script>

<style lang="css">
.noselect {
  user-select: none;
}

.transition {
  height: 100%;

  animation-name: transitionApp;
  animation-duration: 0.5s;
  animation-fill-mode: forwards;
}

@keyframes transitionApp {
  from {
    left: 0%;
  }
  to {
    left: -100%;
  }
}
</style>
