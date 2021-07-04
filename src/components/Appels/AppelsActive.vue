<template>
  <div style="width: 100%; height: 100%;"  class="phone_app">
    <div class="backblur" v-bind:style="{ background: 'url(' + backgroundURL +')' }"></div>
    <InfoBare />
    <div class="num">{{ appelsDisplayNumber }}</div>
    <div class="contactName">{{ formatEmoji(appelsDisplayName) }}</div>

    <div class="time"></div>
    <div class="time-display">{{ timeDisplay }}</div>

    <div class="actionbox">
      <div class="action hangup" :class="{ disableTrue: status === 0 && select !== 0 }">
        <i class="fas fa-phone"></i>
      </div>
      <div class="action answer" v-if="status === 0" :class="{ disableFalse: status === 0 && select !== 1 }">
        <i class="fas fa-phone"></i>
      </div>
    </div>

    <div class="keypad-general-container" :style="[ showingKeypad ? { bottom: '0px' } : {} ]">
      <div class="extra-content-line"></div>

      <div class="keypad-general-input">
        <input :placeholder="LangString('APP_PHONE_KEYPAD_PLACEHOLDER')" :value="numero"/>
      </div>

      <div class="keyboard">
        <div class="key" v-for="(key, i) of keyInfo" :key="key.primary" :class="{ 'key-select': i === keySelect, 'keySpe': key.isNotNumber === true }">
          <span class="key-primary">{{ key.primary }}</span>
          <span class="key-secondary">{{ key.secondary }}</span>
        </div>
      </div>
    </div>

   </div>
</template>

<script>
// eslint-disable-next-line
import { mapGetters, mapActions } from 'vuex'
import InfoBare from './../InfoBare'
export default {
  components: { InfoBare },
  data () {
    return {
      time: -1,
      intervalNum: undefined,
      select: -1,
      status: 0,
      showingKeypad: false,
      numero: '',
      keyInfo: [
        {primary: '1', secondary: ''},
        {primary: '2', secondary: 'abc'},
        {primary: '3', secondary: 'def'},
        {primary: '4', secondary: 'ghi'},
        {primary: '5', secondary: 'jkl'},
        {primary: '6', secondary: 'mmo'},
        {primary: '7', secondary: 'pqrs'},
        {primary: '8', secondary: 'tuv'},
        {primary: '9', secondary: 'wxyz'},
        {primary: '*', secondary: '', isNotNumber: true},
        {primary: '0', secondary: '+'},
        {primary: '#', secondary: '', isNotNumber: true}
      ],
      keySelect: 0
    }
  },
  methods: {
    ...mapActions(['acceptCall', 'rejectCall', 'ignoreCall']),
    formatEmoji (message) {
      return this.$phoneAPI.convertEmoji(message)
    },
    onBackspace () {
      if (this.showingKeypad) {
        this.showingKeypad = false
        return
      }
      if (this.status === 1) { this.onRejectCall() } else { this.onIgnoreCall() }
    },
    onEnter () {
      if (this.showingKeypad) {
        if (this.numero.length >= 25) return
        this.numero += this.keyInfo[this.keySelect].primary
        return
      }
      if (this.status === 0) { this.onAcceptCall() }
    },
    onUp () {
      if (!this.showingKeypad) { this.showingKeypad = true; return }
      if (this.keySelect > 2) {
        this.keySelect = this.keySelect - 3
      }
    },
    onDown () {
      if (!this.showingKeypad) return
      if (this.keySelect > 8) return
      this.keySelect = Math.min(this.keySelect + 3, 11)
    },
    onLeft () {
      if (!this.showingKeypad) return
      this.keySelect = Math.max(this.keySelect - 1, 0)
    },
    onRight () {
      if (!this.showingKeypad) return
      this.keySelect = Math.min(this.keySelect + 1, 11)
    },
    onRejectCall () {
      this.rejectCall()
      this.$phoneAPI.setIgnoreFocus(false)
    },
    onAcceptCall () {
      this.acceptCall()
      this.$phoneAPI.setIgnoreFocus(true)
    },
    onIgnoreCall () {
      this.ignoreCall()
      this.$phoneAPI.setIgnoreFocus(false)
      this.$router.push({ name: 'menu' })
    },
    startTimer () {
      if (this.intervalNum === undefined) {
        this.time = 0
        this.intervalNum = setInterval(() => {
          this.time += 1
        }, 1000)
      }
    }
  },
  watch: {
    appelsInfo () {
      if (this.appelsInfo === null) return
      if (this.appelsInfo.is_accepts === true) {
        this.status = 1
        this.$phoneAPI.setIgnoreFocus(true)
        this.startTimer()
      }
    }
  },
  computed: {
    ...mapGetters(['LangString', 'backgroundURL', 'appelsInfo', 'appelsDisplayName', 'appelsDisplayNumber', 'myPhoneNumber']),
    timeDisplay () {
      if (this.time < 0) { return this.LangString('APP_PHONE_DIALING_MESSAGE') }
      const min = Math.floor(this.time / 60)
      let sec = this.time % 60
      if (sec < 10) { sec = '0' + sec }
      return `${min}:${sec}`
    }
  },
  mounted () {
    if (this.appelsInfo !== null && this.appelsInfo.initiator === true) {
      this.status = 1
      this.$phoneAPI.setIgnoreFocus(true)
    }
  },
  created () {
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    if (this.intervalNum !== undefined) {
      window.clearInterval(this.intervalNum)
    }
    this.$phoneAPI.setIgnoreFocus(false)
  }
}
</script>

<style scoped>
.backblur {
  top: -6px;
  left: -6px;
  right:-6px;
  bottom: -6px;
  position: absolute;
  background-size: cover !important;
  filter: blur(6px);
}

.num {
  position: absolute;
  text-shadow: 0px 0px 15px black, 0px 0px 15px black;
  top: 60px;
  left: 0;
  right: 0;
  color: rgba(255, 255, 255, 0.9);
  text-align: center;
  font-size: 46px;
}

.contactName {
  position: absolute;
  text-shadow: 0px 0px 15px black, 0px 0px 15px black;
  top: 100px;
  left: 0;
  right: 0;
  color: rgba(255, 255, 255, 0.8);
  text-align: center;
  margin-top: 16px;
  font-size: 26px;
}

.time {
  position: relative;
  margin: 0 auto;
  top: 280px;
  left: 0px;
  width: 150px;
  height: 150px;
  border-top: 2px solid white;
  border-radius: 50%;
  animation: rond 1.8s infinite linear;
}

.time-display {
  text-shadow: 0px 0px 15px black, 0px 0px 15px black;
  position: relative;
  top: 187px;
  line-height: 20px;
  left: 0px;
  width: 150px;
  height: 91px;
  color: white;
  font-size: 36px;
  text-align: center;
  margin: 0 auto;
}

.actionbox {
  position: absolute;
  display: flex;
  bottom: 70px;
  left: 0;
  right: 0;
  justify-content: space-around;
}

.action {
  height: 100px;
  width: 100px;
  border-radius: 50%;
}

.hangup {
  text-align: center;
  background-color: #fd3d2e;
  border-radius: 50px;
  height: 80px;
  width: 80px;
}

.hangup i {
  color: #ffffff;
  font-size: 40px;
  padding-bottom: 17px;
  padding-right: 17px;
  transform: rotate(-135deg);
}

.answer {
  text-align: center;
  background-color: #4ddb62;
  border-radius: 50px;
  height: 80px;
  width: 80px;
}

.answer i {
  color: #ffffff;
  font-size: 40px;
  padding-top: 20px;
}

.disableTrue { 
  background-color: #fd3d2e;
  height: 80px;
  width: 80px;
}

.disable { 
  background-color: #4ddb62;
  height: 80px;
  width: 80px;
}

.action svg {
  width: 60px;
  height: 60px;
  margin: 10px;
  fill: #EEE;
}

@keyframes rond {
  from {
    rotate: 0deg
  }
  to {
    rotate: 360deg
  }
}

.extra-content-line {
  width: 70%;
  background-color: white;
  height: 10px;
  border-radius: 20px;
  margin-top: 10px;
  margin-left: auto;
  margin-right: auto;
  box-shadow: 0 2px 5px 2px rgba(0, 0, 0, 0.3);  
}

.keypad-general-container {
  width: 100%;
  height: 86%;
  position: absolute;
  background-color: rgba(95, 95, 95, 0.8);
  bottom: -600px;
  transition: all .4s ease;
  border-radius: 30px;
}

.keypad-general-input {
  position: relative;
  width: 90%;
  height: 50px;
  margin-top: 25px;
  margin-left: auto;
  margin-right: auto;
}

.keypad-general-input input {
  width: 100%;
  height: 100%;
  margin-left: auto;
  margin-right: auto;
  border: none;
  outline: none;
  border-radius: 20px;
  padding-right: 20px;
  font-size: 15px;
  text-align: right;
  box-shadow: 0 2px 5px 2px rgba(0, 0, 0, 0.3);  
}

/* KEYPAD STYLING */

.keyboard {
  display: flex;
  flex-wrap: wrap;
  width: 100%;
}

.key {
  position: relative;
  flex: 1 1 33.33%;
  text-align: center;
  height: 96px;
}

.key-select::after {
  content: '';
  position: absolute;
  top: calc(58% - 45px);
  left: calc(55% - 45px);
  display: block;
  width: 80px;
  height: 80px;
  background: radial-gradient(rgba(255, 255, 255, 0.1), rgba(255, 255, 255, 0.2));
  border-radius: 50%;
}

.key-primary {
  display: block;
  font-size: 36px;
  color: black;
  line-height: 22px;
  padding-top: 34px;
}

.keySpe .key-primary {
  color: #2c3e50;
  line-height: 96px;
  padding: 0;
}

.key-secondary {
  text-transform: uppercase;
  display: block;
  font-size: 12px;
  color: black;
  line-height: 12px;
  padding-top: 8px;
}
</style>
