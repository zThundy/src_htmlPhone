

<template>
   <div class="phone_app">
    <PhoneTitle :backgroundColor="'rgb(78, 144, 61)'" :title="LangString('APP_PHONE_TITLE')" @back="quit" />

    <div class="content">
      <div class="number">
        {{ numeroFormat }}
        <span class="deleteNumber"></span>
      </div>

      <div class="keyboard">
        <div class="key" v-for="(key, i) of keyInfo" :key="key.primary" :class="{ 'key-select': i === keySelect, 'keySpe': key.isNotNumber === true }">
          <span class="key-primary">{{ key.primary }}</span>
          <span class="key-secondary">{{ key.secondary }}</span>
        </div>
      </div>

      <div class="call">
        <div class="call-btn" :class="{ 'active': keySelect === 12 }">
          <i class="fas fa-phone"></i>
        </div>
      </div>

    </div>
   </div>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'
import PhoneTitle from './../PhoneTitle'
export default {
  components: { PhoneTitle },
  data () {
    return {
      numero: '',
      keyInfo: [
        {primary: '1', secondary: '', ascii: 48},
        {primary: '2', secondary: 'abc', ascii: 49},
        {primary: '3', secondary: 'def', ascii: 50},
        {primary: '4', secondary: 'ghi', ascii: 51},
        {primary: '5', secondary: 'jkl', ascii: 52},
        {primary: '6', secondary: 'mmo', ascii: 53},
        {primary: '7', secondary: 'pqrs', ascii: 54},
        {primary: '8', secondary: 'tuv', ascii: 55},
        {primary: '9', secondary: 'wxyz', ascii: 56},
        {primary: '*', secondary: '', isNotNumber: true, ascii: 42},
        {primary: '0', secondary: '+', ascii: 57},
        {primary: '#', secondary: '', isNotNumber: true, ascii: 35}
      ],
      keySelect: 0
    }
  },
  methods: {
    ...mapActions(['startCall']),
    onLeft () {
      this.keySelect = Math.max(this.keySelect - 1, 0)
    },
    onRight () {
      this.keySelect = Math.min(this.keySelect + 1, 11)
    },
    onDown () {
      this.keySelect = Math.min(this.keySelect + 3, 12)
    },
    onUp () {
      if (this.keySelect > 2) {
        if (this.keySelect === 12) {
          this.keySelect = 10
        } else {
          this.keySelect = this.keySelect - 3
        }
      }
    },
    onEnter () {
      if (this.keySelect === 12) {
        if (this.numero.length > 0) {
          this.startCall({ numero: this.numeroFormat })
        }
      } else {
        if (this.numero.length >= 15) return
        this.$phoneAPI.playKeySound({ file: this.keyInfo[this.keySelect].ascii })
        this.numero += this.keyInfo[this.keySelect].primary
      }
    },
    onBackspace () {
      if (this.ignoreControls === true) return
      if (this.numero.length !== 0) {
        this.numero = this.numero.slice(0, -1)
      } else {
        history.back()
      }
    },
    deleteNumber () {
      if (this.numero.length !== 0) {
        this.numero = this.numero.slice(0, -1)
      }
    },
    quit () {
      history.back()
    }
  },

  computed: {
    ...mapGetters(['LangString']),
    numeroFormat () {
      return this.numero
      // if (this.useFormatNumberFrance === true) {
      //   return this.numero
      // }
      // const l = this.numero.startsWith('#') ? 4 : 3
      // if (this.numero.length > l) {
      //   return this.numero.slice(0, l) + '*' + this.numero.slice(l)
      // } else {
      //   return this.numero
      // }
    }
  },

  created () {
    this.$bus.$on('keyUpBackspace', this.onBackspace)
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
  }
}
</script>

<style scoped>
.number {
  margin-top: 140px;
  width: 100%;
  height: 50px;
  font-size: 26px;
  line-height: 52px;

  text-align: right;
  border-bottom: 1px solid #C0C0C0;
  margin-bottom: 0;
  box-shadow: 0px -6px 12px 0px rgba(189,189,189,0.4);
  position: relative;
  padding-right: 50px;
}

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
  background: radial-gradient(rgba(0, 0, 0, 0.02), rgba(0, 0, 0, 0.12));
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

.call {
  height: 60px;
  display: flex;
  justify-content: center;
}

.call-btn {
  height: 70px;
  width: 70px;
  border-radius: 50%;
  background-color: #52d66a;
}

.call-btn i {
  font-size: 35px;
  margin-top: 17px;
  margin-left: 16px;
  color: white;
}

.call-btn.active {
  background-color: #00ff0d;
}

.deleteNumber {
  display: inline-block;
  position: absolute;
  background: #414141;
  top: 16px;
  right: 12px;
  height: 18px;
  width: 25px;
  padding: 0;
}

.deleteNumber:after {
  content: '';
  position: absolute;
  left: -5px;
  top: 0;
  width: 0;
  height: 0;
  border-style: solid;
  border-width: 9px 5px 9px 0;
  border-color: transparent #414141 transparent transparent;
}
</style>
