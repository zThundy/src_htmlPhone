<template>
  <div style="height: 100vh; width: 100vw;">
    <notification />

    <div v-if="show === true && tempoHide === false" :style="getStyle()">

      <div class="phone_wrapper">
        <div v-if="currentCover" class="phone_coque" :style="{ backgroundImage: 'url(/html/static/img/cover/' + currentCover.value + ')' }"></div>
        
          <div id="app" class="phone_screen noselect">
            <!-- <transition-page :isChanging="isChanging"/> :class="{ 'transition': isChanging }" :style="getStyle(brightness)" -->
            
            <router-view />
            <!--
              assegnando i componenti inferiori a vari path posso mostrare più
              router assieme e farci l'animazione
              <router-view style="position: absolute;" name="default"/>
            -->
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
    getStyle () {
      return {
        'zoom': this.zoom
        // 'filter': 'brightness(' + ((this.brightness / 100) + 0.10) + ')'
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

function decimalAdjust (type, value, exp) {
  // If the exp is undefined or zero...
  if (typeof exp === 'undefined' || +exp === 0) {
    return Math[type](value)
  }
  value = +value
  exp = +exp
  // If the value is not a number or the exp is not an integer...
  if (isNaN(value) || !(typeof exp === 'number' && exp % 1 === 0)) {
    return NaN
  }
  // Shift
  value = value.toString().split('e')
  value = Math[type](+(value[0] + 'e' + (value[1] ? (+value[1] - exp) : -exp)))
  // Shift back
  value = value.toString().split('e')
  return +(value[0] + 'e' + (value[1] ? (+value[1] + exp) : exp))
}

// Decimal ceil
if (!Math.ceil10) {
  Math.ceil10 = function (value, exp) {
    return decimalAdjust('ceil', value, exp)
  }
}
// Decimal floor
if (!Math.floor10) {
  Math.floor10 = function (value, exp) {
    return decimalAdjust('floor', value, exp)
  }
}
</script>

<style lang="css">
.noselect {
  user-select: none;
}
</style>
