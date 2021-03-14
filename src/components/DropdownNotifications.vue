<template>
  <div v-if="checkState" class="notificationBox" :class="[ show ? 'downClass' : 'upClass' ]">
    <div class="timeDiv">
      <CurrentTime style="margin-top: 1px;" class="timeDivElements left" />
      <i v-if="notification" style="margin-top: 2px;" class="timeDivElements right fa fa-bell" />
      <i v-else style="margin-top: 2px;" class="timeDivElements right fa fa-bell-slash" />
      
      <i v-if="isWifiOn" style="margin-top: 2px;" class="timeDivElements right fa fa-wifi" />
      <i v-if="airplane" style="margin-top: 2px;" class="timeDivElements right fa fa-plane" />
      <i v-if="bluetooth" style="margin-top: 2px;" class="timeDivElements right fa fa-bluetooth" />
    </div>

    <div class="line"></div>

    <div :class="[ 0 == currentSelectY ? 'select' : '' ]" class="quickOptions">
      <i class="immagine" v-for="(elem, key) in quickPics" v-bind:key="key" :class="[ 'fa ' + elem.img, Boolean(elem.state) ? 'active' : 'notActive', (key == currentSelectX) && (currentSelectY == 0) ? 'selected' : '' ]" />
    </div>

    <div :class="[ 1 == currentSelectY ? 'select' : '' ]">
      <custom-slider :value="brightness"></custom-slider>
    </div>

    <div v-if="hasUnredMessages">
      <div v-for="(elem, key) in unreadMessages" :key="key">
        <div v-if="key < 5" class="separatore"></div>

        <span v-if="key < 4" class="messlist">

          <span class="warningMess_content">
            <div class="transmitter">{{elem.transmitter}}</div>
            <div v-if="!isSMSImage(elem.message)" class="messaggio">{{elem.message}}</div>
            <div v-else class="messaggio">Immagine</div>
          </span>

        </span>

      </div>
    </div>

  </div>
</template>

<script>
import CustomSlider from '@/components/CustomSlider'
import CurrentTime from './CurrentTime'
import { mapGetters, mapActions } from 'vuex'

export default {
  name: 'dropdown-notifications',
  components: {
    CurrentTime,
    CustomSlider
  },
  props: {
    show: {
      type: Boolean,
      default: false
    }
  },
  data () {
    return {
      changingRouter: false,
      currentSelectX: 0,
      currentSelectY: 0,
      hasUnredMessages: false,
      maxY: 1,
      quickPics: []
    }
  },
  computed: {
    ...mapGetters([
      'notification',
      'airplane',
      'isWifiOn',
      'bluetooth',
      'brightness',
      'unreadMessages',
      'UnreadMessagesLength'
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
      'toggleWifi',
      'updateBluetooth',
      'changeBrightness',
      'setupUnreadMessages',
      'resetUnreadMessages'
    ]),
    onLeftNotif () {
      if (this.show) {
        if (this.currentSelectY === 0) {
          if (this.currentSelectX === 0) return
          this.currentSelectX = this.currentSelectX - 1
        } else {
          if (this.brightness === 0) return
          this.changeBrightness(this.brightness - 5)
        }
      }
    },
    onRightNotif () {
      if (this.show) {
        if (this.currentSelectY === 0) {
          if (this.currentSelectX === this.quickPics.length - 1) return
          this.currentSelectX = this.currentSelectX + 1
        } else {
          if (this.brightness === 100) return
          this.changeBrightness(this.brightness + 5)
        }
      }
    },
    onDownNotify () {
      if (this.show) {
        if (this.currentSelectY === this.maxY) return
        this.currentSelectY = this.currentSelectY + 1
      }
    },
    onUpNotify () {
      if (this.show) {
        if (this.currentSelectY === 0) return
        this.currentSelectY = this.currentSelectY - 1
      }
    },
    onEnterNotify () {
      if (this.show) {
        if (this.currentSelectX === -1) return
        var pick = this.quickPics[this.currentSelectX]
        if (pick.meta === 'wifi') {
          this.toggleWifi(!this.isWifiOn)
          pick.state = this.isWifiOn
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
    onBackNotify () {
      this.currentSelectX = 0
      this.currentSelectY = 0
    },
    isSMSImage (mess) {
      var pattern = new RegExp('^(https?:\\/\\/)?' + '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|' + '((\\d{1,3}\\.){3}\\d{1,3}))' + '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*' + '(\\?[;&a-z\\d%_.~+=-]*)?' + '(\\#[-a-z\\d_]*)?$', 'i')
      return !!pattern.test(mess)
    }
  },
  created () {
    this.resetUnreadMessages()
    setTimeout(() => {
      this.setupUnreadMessages()
      if (this.UnreadMessagesLength > 0) { this.hasUnredMessages = true }
    }, 100)

    this.changingRouter = true
    this.quickPics = [
      {meta: 'wifi', img: 'fa-wifi', state: this.isWifiOn},
      {meta: 'bluetooth', img: 'fa-bluetooth-b', state: false},
      {meta: 'notifications', img: 'fa-bell', state: this.notification},
      {meta: 'airplane', img: 'fa-plane', state: this.airplane},
      {meta: 'refresh', img: 'fa-refresh', state: false}
    ]

    this.$bus.$on('keyUpArrowLeft', this.onLeftNotif)
    this.$bus.$on('keyUpArrowRight', this.onRightNotif)
    this.$bus.$on('keyUpArrowDown', this.onDownNotify)
    this.$bus.$on('keyUpArrowUp', this.onUpNotify)
    this.$bus.$on('keyUpEnter', this.onEnterNotify)
    this.$bus.$on('keyUpBackspace', this.onBackNotify)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowLeft', this.onLeftNotif)
    this.$bus.$off('keyUpArrowRight', this.onRightNotif)
    this.$bus.$off('keyUpArrowDown', this.onDownNotify)
    this.$bus.$off('keyUpArrowUp', this.onUpNotify)
    this.$bus.$off('keyUpEnter', this.onEnterNotify)
    this.$bus.$off('keyUpBackspace', this.onBackNotify)
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

/* ////////////////// */
/* MESSAGGI NON LETTI */
/* ////////////////// */

.messlist {
  position: relative;

  margin-left: auto;
  margin-right: auto;

  width: 300px;
  display: flex;
}

.messlist .warningMess_icon{
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  height: 42px;
  width: 40px;
  border-radius: 50%;
}

.messlist .warningMess_content{
  line-height: 20px;
  padding-left: 10px;
}

.transmitter {
  padding-top: 4px;
  font-size: 15px;
  color: rgb(0, 0, 0);
  font-weight: bolder;
}

.messaggio {
  padding-top: 0px;
  padding-left: 4px;
  font-weight: bold;
  font-size: 15px;
  color: rgba(34, 34, 34, 0.555);
}

.separatore {
  position: relative;
  width: 88%;
  margin-top: 2%;
  margin-right: auto;
  margin-left: auto;
  border-bottom: 1px solid rgba(128, 128, 128, 0.425);
}

.warningMess_title {
  font-size: 20px;
}

.warningMess_mess {
  font-size: 16px;
}
</style>
