<template>
  <div style="width: 100%; height: 100%;" class="phone_app">
    <PhoneTitle :title="LangString('APP_AZIENDA_TITLE')" :color="'black'" backgroundColor="rgb(255, 180, 89)"/>

    <div v-if="myJobInfo && myJobInfo.buttons" class="container">
      <div class="informations-container">
        <div class="informations-head">
          <img :src="myAziendaInfo.img ? myAziendaInfo.img : '/html/static/img/icons_app/azienda.png'">
          <div class="informations-inline">
            <span class="informations-label">
              {{ myJobInfo.name }}
            </span>
            <p class="informations-money">
              <md-amount class="bankAmount" :value="myAziendaInfo.money" :duration="1500" has-separator transition></md-amount>$
            </p>
          </div>
        </div>
      </div>
        
      <div class="informations-line">
        <div class="informations-divider">
          <span class="informations-azienda-label">{{ myAziendaInfo.label }}</span>
        </div>
      </div>

      <div class="buttons-container">
        <div v-for="(val, key) in appButtons" :key="key">
          <input type='button' class="generic-button" :class="{ select: currentSelect == key }" :value="LangString(val.label)" />
        </div>
      </div>
    </div>
    
    <div v-else class="middle-text">
      <span>{{ LangString("APP_AZIENDA_NO_AZIENDA") }}</span>
      <i class="fa fa-frown-o" aria-hidden="true"></i>
    </div>

    <div class="extra-content" :class="[ showingComponent && animate ? 'extra-content-up' : 'extra-content-down' ]" :style="{ visibility: this.changingRouter }">
      <div class="extra-content-line"></div>

      <div v-if="showingComponent && COMPONENTS[showingComponent]">
        <component v-bind:is="COMPONENTS[showingComponent]"/>
      </div>
      
      <div v-else class="extra-content-error">
        <div class="extra-content-error-bg">
          <span>{{ LangString("APP_AZIENDA_ERROR_LOADING") }}</span>
          <i class="fa fa-frown-o" aria-hidden="true"></i>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
import PhoneTitle from './../PhoneTitle'
import { mapGetters, mapMutations } from 'vuex'

import AziendaChat from './aziendachat'
import AziendaEmployes from './aziendaemployes'
import AziendaCalls from './aziendacalls'

import { Amount } from 'mand-mobile'
import 'mand-mobile/lib/mand-mobile.css'
// import Vue from 'vue'

export default {
  name: 'azienda-screen',
  components: {
    PhoneTitle,
    [Amount.name]: Amount
  },
  data () {
    return {
      currentSelect: -1,
      showingComponent: null,
      COMPONENTS: {
        'chat': AziendaChat,
        'employes': AziendaEmployes,
        'calls': AziendaCalls
      },
      animate: false,
      changingRouter: 'hidden'
    }
  },
  computed: {
    ...mapGetters(['LangString', 'myJobInfo', 'myAziendaInfo', 'buttons', 'aziendaIngoreControls']),
    appButtons () {
      return this.buttons.filter(element => this.myJobInfo.buttons[element.id] !== null && this.myJobInfo.buttons[element.id] !== undefined)
    }
  },
  watch: {
  },
  methods: {
    ...mapMutations(['SET_AZIENDA_IGNORE_CONTROLS']),
    onUp () {
      if (this.aziendaIngoreControls) return
      if (this.showingComponent) return
      if (this.currentSelect === -1) return
      this.currentSelect = this.currentSelect - 1
      // this.checkButtonsOnScroll(true)
    },
    onDown () {
      if (this.aziendaIngoreControls) return
      if (this.showingComponent) return
      if (this.currentSelect === this.appButtons.length - 1) return
      this.currentSelect = this.currentSelect + 1
      // this.checkButtonsOnScroll(false)
    },
    onEnter () {
      if (this.aziendaIngoreControls) return
      if (this.showingComponent) return
      if (this.currentSelect === -1) return
      if (!this.myJobInfo) return
      if (!this.myJobInfo.buttons[this.appButtons[this.currentSelect].id]) return
      this.showingComponent = this.appButtons[this.currentSelect].id
      this.animate = true
      this.SET_AZIENDA_IGNORE_CONTROLS(true)
      setTimeout(() => {
        this.SET_AZIENDA_IGNORE_CONTROLS(false)
      }, 600)
      // this.$router.push({ name: 'azienda_' + this.buttons[this.currentSelect].id })
    },
    onBack () {
      if (this.aziendaIngoreControls) return
      if (this.showingComponent) {
        this.animate = false
        setTimeout(() => {
          this.showingComponent = null
        }, 300)
        return
      }
      this.$router.push({ name: 'menu' })
    } // ,
    // checkButtonsOnScroll (up) {
    //   if (this.currentSelect === -1) return
    //   if (!this.myJobInfo.buttons[this.buttons[this.currentSelect].id]) {
    //     if (!up) {
    //       if (this.currentSelect === 0) {
    //         this.currentSelect = 1
    //       } else if (this.currentSelect === 1) {
    //         this.currentSelect = 2
    //       }
    //     } else {
    //       if (this.currentSelect === 2) {
    //         this.currentSelect = 1
    //       } else if (this.currentSelect === 1) {
    //         this.currentSelect = 0
    //       }
    //     }
    //   }
    // }
  },
  created () {
    setTimeout(() => {
      this.changingRouter = 'visible'
    }, 400)
    this.$phoneAPI.requestJobInfo()
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  mounted () {
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.container {
  height: 100%;
  background-color: rgb(85, 85, 85);
}

.informations-container {
  height: 18%;
  background-color: bisque;
}

.informations-inline {
  width: 100%;
  margin-left: 12px;
}

.informations-head {
  margin-top: 20px;
  margin-left: 20px;

  display: inline-flex;
  width: 90%;
  justify-content: space-between;
}

.informations-money {
  font-size: 12px;
  margin-top: 5px;
}

.informations-money span {
  font-size: 15px;
  margin-right: 4px;
}

.informations-label {
  font-size: 25px;
  font-weight: bold;
}

.informations-head img {
  width: 60px;
  height: 60px;

  border-radius: 50%;
  border: 1px solid black;
}

.informations-line {
  position: relative;
  background-color: rgb(0, 0, 0);
  width: 100%;
  height: 1px;
}

.informations-azienda-label {
  display: block;
  height: fit-content;
  text-align: center;
  margin: auto;
  padding-top: 6px;
}

.informations-divider {
  position: absolute;
  border: 1px solid rgba(0, 0, 0, 0.5);
  /* background-color: rgb(241, 171, 84); */
  background-color: rgb(241, 171, 84);
  width: 88%;
  height: 40px;
  border-radius: 20px;
  top: -20px;
  
  left: 0;
  right: 0;
  margin-left: auto;
  margin-right: auto;
}

.buttons-container {
  position: relative;
  display: flex;
  flex-direction: column;

  align-items: center;
}

.generic-button.select {
  background-color: rgb(255, 180, 89);
}

.generic-button {
  width: 250px;
  height: 50px;
  margin-top: 30%;

  border: none;
  border-radius: 20px;
  background-color: rgb(255, 215, 167);
}


.middle-text {
  margin: auto;
}

.middle-text span {
  vertical-align: middle;
  color: grey;
}

.middle-text i {
  vertical-align: middle;
  color: grey;
}

.extra-content {
  position: absolute;
  width: 330px;
  height: 650px;
  bottom: 0;
  background-color: rgb(128, 128, 128);
  border-radius: 30px 30px 0px 0px;
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

.extra-content-up {
  animation-name: up;
  animation-duration: 0.3s;
  animation-fill-mode: both;
}

@keyframes up {
  from { bottom: -650px; }
  to { bottom: 0; }
}

.extra-content-down {
  animation-name: down;
  animation-duration: 0.3s;
  animation-fill-mode: both;
}

@keyframes down {
  from { bottom: 0; }
  to { bottom: -650px; }
}

.extra-content-error {
  display: block;
  text-align: center;
  text-align: -webkit-center;

  margin-top: 90%;
}

.extra-content-error-bg {
  width: 80%;
  height: 50px;
  border-radius: 50px;
  background-color: rgba(0, 0, 0, 0.3);
  padding-top: 10px;
}

.extra-content-error span {
  vertical-align: middle;
  color: rgb(0, 0, 0);
  font-weight: bold;
}

.extra-content-error i {
  vertical-align: middle;
  color: rgb(0, 0, 0);
  font-weight: bold;
}
</style>
