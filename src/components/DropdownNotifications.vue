<template>
  <div v-if="checkState" class="notificationBox" :class="[ show ? 'downClass' : 'upClass' ]">
    <div class="timeDiv">
      <CurrentTime style="margin-top: 1px;" class="timeDivElements left" />
      <i v-if="notification" style="margin-top: 2px;" class="timeDivElements right fa fa-bell" />
      <i v-else style="margin-top: 2px;" class="timeDivElements right fa fa-bell-slash" />
      
      <i v-if="airplane" style="margin-top: 2px;" class="timeDivElements right fa fa-plane" />
    </div>

    <div class="line"></div>

    <div class="quickOptions">
      <i class="immagine" v-for="(elem, key) in quickPics" v-bind:key="key" :class="[ 'fa ' + elem.img, Boolean(elem.state) ? 'active' : 'notActive', key == currentSelect ? 'selected' : '' ]" />
    </div>

  </div>
</template>

<script>
import CurrentTime from './CurrentTime'
import { mapGetters, mapActions } from 'vuex'

export default {
  name: 'dropdown-notifications',
  components: { CurrentTime },
  props: {
    show: {
      type: Boolean,
      default: false
    }
  },
  data () {
    return {
      changingRouter: false,
      currentSelect: -1,
      quickPics: []
    }
  },
  computed: {
    ...mapGetters([
      'notification',
      'airplane',
      'hasWifi',
      'bluetooth'
    ]),
    checkState () {
      if (this.show) {
        this.changingRouter = false
      }
      // console.log(this.changingRouter, this.show)
      return !this.changingRouter
    }
  },
  methods: {
    ...mapActions([
      'toggleNotifications',
      'toggleAirplane',
      'updateWifiString',
      'updateBluetooth'
    ]),
    onLeftNotif () {
      if (this.currentSelect === -1) return
      this.currentSelect = this.currentSelect - 1
    },
    onRightNotif () {
      if (this.currentSelect === this.quickPics.length - 1) return
      this.currentSelect = this.currentSelect + 1
    },
    onEnterNotify () {
      if (this.currentSelect === -1) return
      var pick = this.quickPics[this.currentSelect]
      if (pick.meta === 'wifi') {
        this.updateWifiString(!this.hasWifi)
        pick.state = this.hasWifi
      } else if (pick.meta === 'notifications') {
        this.toggleNotifications()
        pick.state = this.notification
      } else if (pick.meta === 'airplane') {
        this.toggleAirplane()
        pick.state = this.airplane
      } else if (pick.meta === 'bluetooth') {
        this.updateBluetooth(!this.bluetooth)
        pick.state = this.bluetooth
      } else if (pick.meta === 'refresh') {
        pick.state = !pick.state
      }
    }
  },
  created () {
    this.changingRouter = true

    this.quickPics = [
      {meta: 'wifi', img: 'fa-wifi', state: this.hasWifi},
      {meta: 'bluetooth', img: 'fa-bluetooth-b', state: false},
      {meta: 'notifications', img: 'fa-bell', state: this.notification},
      {meta: 'airplane', img: 'fa-plane', state: this.airplane},
      {meta: 'refresh', img: 'fa-refresh', state: false}
    ]

    this.$bus.$on('keyUpArrowLeft', this.onLeftNotif)
    this.$bus.$on('keyUpArrowRight', this.onRightNotif)
    // this.$bus.$on('keyUpArrowDown', this.onDown)
    // this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnterNotify)
    // this.$bus.$on('keyUpBackspace', this.onBack)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowLeft', this.onLeftNotif)
    this.$bus.$off('keyUpArrowRight', this.onRightNotif)
    // this.$bus.$off('keyUpArrowDown', this.onDown)
    // this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnterNotify)
    // this.$bus.$off('keyUpBackspace', this.onBack)
  },
  beforeCreate () { }
}
</script>

<style scoped>
.notificationBox {
  position: absolute;
  width: 100%;
  background-color: rgb(255, 255, 255);
  border-radius: 30px;
  height: 50%;
}

.timeDiv {
  width: 100%;
  height: 10%;
  top: 5px;
}

.timeDivElements {
  position: relative;
  top: 30%;
}

.left {
  float: left;
  left: 5%;
}

.right {
  float: right;
  right: 3%;
  letter-spacing: 8px;
}

.line {
  width: 88%;
  margin-top: 2%;
  margin-right: auto;
  margin-left: auto;
  border-bottom: 1px solid grey;
}

.quickOptions {
  margin-top: 20px;
  display: flex;
  width: 100%;
  align-items: flex-start;
  align-content: flex-start;
  /* justify-content: space-around; */

  margin-left: auto;
  margin-right: auto;

  flex-flow: row;
  flex-wrap: wrap;
}

.immagine {
  position: relative;
  margin-left: auto;
  margin-right: auto;

  width: 20px;
}

.selected {
  /* background-color: rgba(92, 92, 92, 0.2); */
  filter: brightness(1.4);
}

.notActive {
  animation-name: changeNotActiveState;
  animation-duration: 0.5s;
  animation-fill-mode: both;
}

@keyframes changeNotActiveState {
  from { color: rgb(0, 144, 228) }
  to { color: grey }
}

.active {
  animation-name: changeActiveState;
  animation-duration: 0.5s;
  animation-fill-mode: both;
}

@keyframes changeActiveState {
  from { color: grey }
  to { color: rgb(0, 144, 228) }
}







/* ANIMAZIONE */

.downClass {
  animation-name: down;
  animation-duration: 0.5s;
  animation-fill-mode: forwards;
}

@keyframes down {
  0% { top: -50%; }
  50% { top: 0 }
  60% { height: 54%; }
  100% { height: 50%; }
}

.upClass {
  animation-name: up;
  animation-duration: 0.3s;
  animation-fill-mode: forwards;
}

@keyframes up {
  from { top: 0%; }
  to { top: -50%; }
}
</style>
