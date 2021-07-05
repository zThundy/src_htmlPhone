<template>
  <div style="height: 100vh; width: 100vw;">
    <!-- <canvas id="self-render" class="content-area"></canvas> -->
    <!-- <div style="width: 50%; height: 50%; background-color: rgba(0,0,0,0.5)"></div> -->
    <!-- <canvas class="video-recorder-canvas" id="video-recorder-canvas"></canvas> -->

    <div v-if="show === true && tempoHide === false" :style="getStyle()">
      <div class="phone_wrapper" :style="classObject()">
        <div v-if="currentCover" class="phone_coque" :style="{ backgroundImage: 'url(/html/static/img/cover/' + currentCover.value + ')' }"></div>
        
        <div v-if="loaded" id="app" class="phone_screen noselect">
          <!-- <transition-page :isChanging="isChanging"/> :class="{ 'transition': isChanging }" :style="getStyle(brightness)" -->
          <!-- <video id="target-stream" class="content-area" style="display: none;" autoplay muted></video> -->
          <notification />

          <router-view />
          <!--
            assegnando i componenti inferiori a vari path posso mostrare più
            router assieme e farci l'animazione
            <router-view style="position: absolute;" name="default"/>
          -->
        </div>

        <div v-if="!loaded" id="app" class="blocked-screen noselect">
          <div class="blocked-screen-flex">
            <span>You can't access to this resource</span>
            <span>Please contact zThundy__#2456 on discord to buy this resource or request access in case of ip change</span>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>

import './PhoneBaseStyle.scss'
import './assets/css/font-awesome.min.css'
import './assets/css/cssgram.css'

import { mapGetters, mapActions } from 'vuex'
import Notification from '@/components/Notification/Notification'

export default {
  name: 'app',
  components: { Notification },
  data () {
    return {
      soundCall: null,
      isChanging: false,
      currentRoute: window.location.pathname,
      audioElement: new Audio()
    }
  },
  methods: {
    ...mapActions(['loadConfig', 'rejectCall']),
    closePhone () {
      this.$phoneAPI.closePhone()
    },
    getStyle () {
      return { 'zoom': this.zoom }
    },
    classObject () {
      if (this.brightnessActive) {
        return { filter: 'brightness(' + ((this.brightness / 100) + 0.10) + ')' }
      }
      return {}
    }
  },
  computed: {
    ...mapGetters(['loaded', 'show', 'zoom', 'currentCover', 'suoneria', 'appelsInfo', 'myPhoneNumber', 'volume', 'tempoHide', 'brightness', 'brightnessActive'])
  },
  watch: {
    appelsInfo (newValue, oldValue) {
      if (this.appelsInfo !== null && this.appelsInfo.is_accepts !== true) {
        if (this.soundCall !== null) { this.soundCall.pause() }
        var path = null
        if (this.appelsInfo.initiator === true) {
          path = '/html/static/sound/Phone_Call_Sound_Effect.ogg'
          this.audioElement.loop = true
        } else {
          path = '/html/static/sound/' + this.suoneria.value
        }
        this.audioElement.src = path
        this.soundCall = this.audioElement
        this.soundCall.volume = this.volume
        this.soundCall.play()
      } else if (this.soundCall !== null) {
        this.soundCall.pause()
        this.soundCall = null
      }
      if (newValue === null && oldValue !== null) { this.$router.push({ name: 'lockscreen' }); return }
      if (newValue !== null) { this.$router.push({ name: 'appels.active' }) }
    },
    show () {
      if (this.appelsInfo !== null) {
        this.$router.push({ name: 'appels.active' })
      } else {
        this.$router.push({ name: 'lockscreen' })
      }
      if (this.show === false && this.appelsInfo !== null) { this.rejectCall() }
    }
  },
  mounted () {
    this.loadConfig()
    window.addEventListener('message', (event) => {
      if (event.data.keyUp !== undefined) { this.$bus.$emit('keyUp' + event.data.keyUp) }
    })
    window.addEventListener('keyup', (event) => {
      const keyValid = ['ArrowRight', 'ArrowLeft', 'ArrowUp', 'ArrowDown', 'Backspace', 'Enter']
      if (keyValid.indexOf(event.key) !== -1) {
        this.$bus.$emit('keyUp' + event.key)
        if (event.key === 'Backspace') { }
      }
      if (event.key === 'Escape') { this.$phoneAPI.closePhone() }
    })
  },
  created () {
    this.$router.push({ name: 'lockscreen' })
    // this.$router.beforeEach((to, from, next) => {
    //   if ((to.meta !== undefined && to.meta !== null) && (from.meta !== undefined && from.meta !== null)) {
    //     // se stai arrivando da un router che si trova più in alto
    //     // (indice maggiore) di quello a cui stai andando, fai l'animazione
    //     if (to.meta.depth > from.meta.depth) {
    //       this.isChanging = true
    //     }
    //     // if (from.meta.depth > to.meta.depth) {
    //     //   this.index = from.meta.depth
    //     // }
    //   }
    //   setTimeout(() => {
    //     this.isChanging = false
    //   }, 500)
    //   next()
    // })

    // function dev () {
    //   Vue.notify({
    //     message: 'Messaggio superfiko inviato da qualcuno',
    //     title: '55537282' + ':',
    //     icon: 'envelope',
    //     backgroundColor: 'rgb(255, 140, 30)',
    //     appName: 'Messaggi'
    //   })
    //   setTimeout(() => {
    //     dev()
    //   }, 1000)
    // }
    // dev()
  }
}
</script>

<style lang="css">
.noselect {
  user-select: none;
}

.blocked-screen {
  overflow: hidden;
  position: absolute;
  background-color: white;
  width: 330px;
  height: 742px;
  bottom: 100px;
  left: 48px;
  right: 50px;
  top: 100px;
  border-radius: 6px;

  background-color: grey;
}

.blocked-screen-flex {
  width: 100%;
  height: 100%;

  display: flex;
  flex-direction: column;
}

.blocked-screen-flex span {
  color: white;
  align-self: center;
  margin: auto;
  text-align: center;
}
</style>
