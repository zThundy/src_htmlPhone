<template>
  <div style="background-color: rgb(240, 240, 240)" class="phone_app">
    <PhoneTitle :title="LangString('APP_CONFIG_TITLE')" :backgroundColor="'rgb(255, 255, 255)'" :textColor="'black'" @back="onBackspace"/>

    <div class="infoContainer">
      <div class="whiteContainer">
        <img class="immagine" v-if="myImage != null" :src="myImage"/>
        <img class="immagine" v-else src="/html/static/img/app_settings/userpic.png"/>

        <span class="picText_label">{{ myData.firstname }} {{ myData.lastname }}</span>
        <span class="picText_value">{{ myData.job }} | {{ myData.job2 }}</span>
      </div>
    </div>

    <div class='phone_content' style="overflow: hidden;">
      <div class='element' v-for='(elem, key) in paramList' v-bind:class="{ select: key === currentSelect }" v-bind:key="key">
        <i class="fa" v-bind:class="elem.icons" v-bind:style="{ color: elem.color }"></i>

        <div class="element-content">
          <span class="element-title">{{ elem.title }}</span>
          <span v-if="elem.value" class="element-value">{{ elem.value }}</span>

          <div class="switchDiv">
            <CustomSwitch v-if="elem.bottone != undefined" class="bottone" :backgroundColor="'#002853'" v-model="bottone[elem.meta]"/>
          </div>
          <md-icon v-if="elem.bottone == undefined" class="rightArrow md-notice-demo-icon md-notice-demo-icon-left" :size="'1'" :name="'arrow-right'"></md-icon>
        </div>

      </div>
    </div>
    
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import PhoneTitle from './../PhoneTitle'
import Modal from '@/components/Modal/index.js'

import CustomSwitch from '@/components/CustomSwitch'

import { Icon } from 'mand-mobile'
import 'mand-mobile/lib/mand-mobile.css'

export default {
  components: {
    PhoneTitle,
    CustomSwitch,
    [Icon.name]: Icon
  },
  data () {
    return {
      ignoreControls: false,
      currentSelect: 0,
      retiWifiRender: [],
      closestPlayersRender: [],
      bottone: []
    }
  },
  computed: {
    ...mapGetters(['LangString', 'myPhoneNumber', 'backgroundLabel', 'suoneriaLabel', 'zoom', 'config', 'volume', 'availableLanguages', 'wifiString', 'retiWifi', 'notification', 'airplane', 'bluetooth', 'currentCover', 'myCovers', 'myImage', 'myData', 'isWifiOn']),
    paramList () {
      // stringa di conferma reset
      const confirmResetStr = this.LangString('APP_CONFIG_RESET_CONFIRM')
      const confirmReset = {}
      confirmReset[confirmResetStr] = {value: 'accept', icons: 'fa-exclamation-triangle'}
      // stringa di annulla
      const cancelStr = this.LangString('CANCEL')
      const cancelTB = {}
      cancelTB[cancelStr] = {value: 'cancel', icons: 'fa-undo', color: 'red'}
      // stringa di nessuna cover
      const nessunaCover = {}
      nessunaCover['Nessuna cover'] = {value: 'base.png', label: 'Nessuna cover', color: 'orange'}
      return [
        {
          icons: 'fa-phone',
          title: this.LangString('APP_CONFIG_MY_MUNBER'),
          value: this.myPhoneNumber
        },
        {
          meta: 'wifi',
          icons: 'fa-wifi',
          onValid: 'connectToWifi',
          title: this.LangString('APP_CONFIG_WIFI'),
          value: this.wifiString,
          values: []
        },
        {
          meta: 'bluetooth',
          icons: 'fa-bluetooth-b',
          onValid: 'toggleBluetoothLocally',
          title: this.LangString('APP_CONFIG_BLUETOOTH'),
          value: (this.bluetooth) ? this.LangString('APP_CONFIG_ENABLED_2') : this.LangString('APP_CONFIG_DISABLED_2'),
          bottone: true
        },
        {
          meta: 'notifications',
          icons: 'fa-bell',
          onValid: 'toggleNotificationsLocally',
          title: this.LangString('APP_CONFIG_NOTIFICATION'),
          value: (this.notification) ? this.LangString('APP_CONFIG_ENABLED_3') : this.LangString('APP_CONFIG_DISABLED_3'),
          bottone: true
        },
        {
          meta: 'airplane',
          icons: 'fa-plane',
          onValid: 'toggleAirplaneModeLocally',
          title: this.LangString('APP_CONFIG_AIRPLANE_MODE'),
          value: (this.airplane) ? this.LangString('APP_CONFIG_ENABLED_1') : this.LangString('APP_CONFIG_DISABLED_1'),
          bottone: true
        },
        {
          meta: 'background',
          icons: 'fa-image',
          title: this.LangString('APP_CONFIG_WALLPAPER'),
          value: this.backgroundLabel,
          onValid: 'onChangeBackground',
          values: this.config.background
        },
        {
          meta: 'cover',
          icons: 'fa-mobile',
          title: this.LangString('APP_CONFIG_CASE'),
          value: this.currentCover.label,
          onValid: 'onChangeCover',
          values: {
            ...this.myCovers,
            ...nessunaCover,
            ...cancelTB
          }
        },
        {
          meta: 'suoneria',
          icons: 'fa-bell-o',
          title: this.LangString('APP_CONFIG_SOUND'),
          value: this.suoneriaLabel,
          onValid: 'onChangesuoneria',
          values: this.config.suoneria
        },
        {
          icons: 'fa-search',
          title: this.LangString('APP_CONFIG_ZOOM'),
          value: this.zoom,
          onValid: 'setLocalZoom',
          onLeft: this.ajustZoom(-1),
          onRight: this.ajustZoom(1),
          values: {
            '100 %': {value: '100%', icons: 'fa-search-plus'},
            '80 %': {value: '80%', icons: 'fa-search-plus'},
            '60 %': {value: '60%', icons: 'fa-search-plus'},
            '40 %': {value: '40%', icons: 'fa-search-minus'},
            '20 %': {value: '20%', icons: 'fa-search-minus'}
          }
        },
        {
          icons: 'fa-volume-down',
          title: this.LangString('APP_CONFIG_VOLUME'),
          value: this.valumeDisplay,
          onValid: 'setPhoneVolume',
          onLeft: this.ajustVolume(-0.01),
          onRight: this.ajustVolume(0.01),
          values: {
            '100 %': {value: 1, icons: 'fa-volume-up'},
            '80 %': {value: 0.8, icons: 'fa-volume-up'},
            '60 %': {value: 0.6, icons: 'fa-volume-up'},
            '40 %': {value: 0.4, icons: 'fa-volume-down'},
            '20 %': {value: 0.2, icons: 'fa-volume-down'},
            '0 %': {value: 0, icons: 'fa-volume-off'}
          }
        },
        // {
        //   icons: 'fa-microphone',
        //   onValid: 'toggleTextToSpeech',
        //   title: this.LangString('APP_CONFIG_TEXT_TO_SPEECH'),
        //   value: (this.tts) ? 'Attiva' : 'Disattiva'
        // },
        {
          icons: 'fa-globe',
          title: this.LangString('APP_CONFIG_LANGUAGE'),
          onValid: 'onChangeLanguages',
          values: {
            ...this.availableLanguages,
            ...cancelTB
          }
        },
        {
          icons: 'fa-exclamation-triangle',
          color: '#ee3838',
          title: this.LangString('APP_CONFIG_RESET'),
          onValid: 'resetPhone',
          values: {
            ...cancelTB,
            ...confirmReset
          }
        }
      ]
    },
    valumeDisplay () {
      return `${Math.floor(this.volume * 100)} %`
    }
  },
  methods: {
    ...mapActions(['getIntlString', 'setZoom', 'setBackground', 'setCurrentCover', 'setsuoneria', 'setVolume', 'setLanguage', 'toggleNotifications', 'toggleAirplane', 'updateWifiString', 'toggleWifi', 'toggleBluetooth']),
    scrollIntoView: function () {
      this.$nextTick(() => {
        document.querySelector('.select').scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' })
      })
    },

    updateWifiTable () {
      this.retiWifiRender = []
      if (this.isWifiOn) {
        for (var i in this.retiWifi) {
          this.retiWifiRender[this.retiWifi[i].label] = { id: i, icons: 'fa-wifi', label: this.retiWifi[i].label, password: this.retiWifi[i].password, value: this.retiWifi[i].password }
        }
        this.retiWifiRender['Annulla'] = { icons: 'fa-undo', label: 'Annulla', value: 'cancel', color: 'red' }
      } else {
        this.retiWifiRender['Wifi spento'] = { icons: 'fa-ban', label: 'Wifi spento', value: 'cancel', color: 'red' }
      }
      return this.retiWifiRender
    },

    onBackspace () {
      if (this.ignoreControls === true) return
      this.$router.push({ name: 'menu' })
    },

    onUp: function () {
      if (this.ignoreControls === true) return
      this.currentSelect = this.currentSelect === 0 ? 0 : this.currentSelect - 1
      this.scrollIntoView()
    },

    onDown: function () {
      if (this.ignoreControls === true) return
      this.currentSelect = this.currentSelect === this.paramList.length - 1 ? this.currentSelect : this.currentSelect + 1
      this.scrollIntoView()
    },

    onRight () {
      if (this.ignoreControls === true) return
      if (this.ignoreControls === true) return
      let param = this.paramList[this.currentSelect]
      if (param.onRight !== undefined) {
        param.onRight(param)
        return
      }
      // qui controllo se il parametro ha un submenu
      if (param.meta !== undefined && param.meta === 'wifi') {
        this.paramList[this.currentSelect].values = this.updateWifiTable()
      }
      this.actionItem(param)
    },

    onEnter () {
      if (this.ignoreControls === true) return
      if (this.paramList[this.currentSelect].meta !== undefined && this.paramList[this.currentSelect].meta === 'wifi') {
        this.paramList[this.currentSelect].values = this.updateWifiTable()
      }
      this.actionItem(this.paramList[this.currentSelect])
    },

    onLeft () {
      if (this.ignoreControls === true) return
      let param = this.paramList[this.currentSelect]
      if (param.onLeft !== undefined) {
        param.onLeft(param)
      }
    },

    actionItem (param) {
      if (param.values !== undefined) {
        this.ignoreControls = true
        let scelte = Object.keys(param.values).map(key => {
          // qui ho un controllo custom per le cover
          if (param.meta !== undefined || param.meta !== null) {
            if (param.meta === 'cover' && param.values[key].value !== 'cancel') {
              if (param.values[key].color === undefined || param.values[key].color === null) {
                return {title: key, value: param.values[key].value, picto: param.values[key].value, icons: 'fa-mobile'}
              } else {
                return {title: key, value: param.values[key].value, picto: param.values[key].value, icons: 'fa-mobile', color: param.values[key].color}
              }
            }
            if (param.meta === 'background') {
              return {title: key, value: param.values[key], picto: param.values[key], icons: 'fa-image'}
            }
            if (param.meta === 'suoneria') {
              return {title: key, value: param.values[key], picto: param.values[key], icons: 'fa-bell'}
            }
          }
          if (param.values[key].value !== undefined) {
            // controllo sui colori
            if (param.values[key].color !== undefined) {
              return {title: key, value: param.values[key].value, picto: param.values[key].value, icons: param.values[key].icons, color: param.values[key].color}
            }
            // questo return va se non ci sta il colore defiito
            return {title: key, value: param.values[key].value, picto: param.values[key].value, icons: param.values[key].icons}
          } else {
            return {title: key, value: param.values[key], picto: param.values[key]}
          }
        })
        Modal.CreateModal({ scelte }).then(reponse => {
          this.ignoreControls = false
          if (reponse.title === 'cancel' || reponse.value === 'cancel') return
          this[param.onValid](param, reponse)
        })
      }
      // qui controllo se le values non sono definite
      if (param.values === undefined && param.onValid !== undefined && param.onValid !== null) {
        this[param.onValid]()
      }
    },

    async onChangeBackground (param, data) {
      let val = data.value
      if (val === 'Link') {
        this.ignoreControls = true
        let scelte = [
          {id: 1, title: this.LangString('APP_CONFIG_LINK_PICTURE'), icons: 'fa-link'},
          {id: 2, title: this.LangString('APP_CONFIG_TAKE_PICTURE'), icons: 'fa-camera'}
        ]
        const resp = await Modal.CreateModal({ scelte: scelte })
        if (resp.id === 1) {
          Modal.CreateTextModal({ text: 'https://i.imgur.com/' }).then(valueText => {
            if (valueText.text !== '' && valueText.text !== undefined && valueText.text !== null && valueText.text !== 'https://i.imgur.com/') {
              this.setBackground({ label: 'Personalizzato', value: valueText.text })
              this.ignoreControls = false
            }
          })
        } else if (resp.id === 2) {
          const pic = await this.$phoneAPI.takePhoto()
          if (pic && pic !== '') {
            this.setBackground({ label: 'Personalizzato', value: pic })
            this.ignoreControls = false
          }
        } else {
          this.ignoreControls = false
        }
      } else {
        this.setBackground({ label: data.title, value: data.value })
        this.ignoreControls = false
      }
    },

    async connectToWifi (param, data) {
      if (!this.isWifiOn) {
        this.toggleWifi(!this.isWifiOn)
        return
      }
      var password = data.value
      this.ignoreControls = true
      Modal.CreateTextModal({ text: '' }).then(valueText => {
        if (valueText.text !== '' && valueText.text !== undefined && valueText.text !== null) {
          if (valueText.text === password) {
            // console.log('hey ai azzecato! :P')
            this.$phoneAPI.connettiAllaRete(this.retiWifiRender[data.title])
            this.updateWifiString(true)
            this.ignoreControls = false
          } else {
            // console.log('no azzecato :(')
            this.$phoneAPI.connettiAllaRete(false)
            this.updateWifiString(false)
            this.ignoreControls = false
          }
        }
      })
    },

    onChangeCover: function (param, data) {
      this.setCurrentCover({ label: data.title, value: data.value })
      this.$phoneAPI.changingCover({ label: data.title, value: data.value })
    },

    onChangesuoneria: function (param, data) {
      this.setsuoneria({ label: data.title, value: data.value })
    },

    setLocalZoom: function (param, data) {
      this.setZoom(data.value)
    },

    ajustZoom (inc) {
      return () => {
        const percent = Math.max(10, (parseInt(this.zoom) || 100) + inc)
        this.setZoom(`${percent}%`)
      }
    },

    setPhoneVolume (param, data) {
      this.setVolume(data.value)
    },

    ajustVolume (inc) {
      return () => {
        const newVolume = Math.max(0, Math.min(1, parseFloat(this.volume) + inc))
        this.setVolume(newVolume)
      }
    },

    onChangeLanguages (param, data) {
      if (data.value !== 'cancel') {
        this.setLanguage(data.value)
      }
    },

    toggleBluetoothLocally () {
      this.toggleBluetooth()
      this.bottone['bluetooth'] = Boolean(this.bluetooth)
    },

    toggleNotificationsLocally () {
      this.toggleNotifications()
      this.bottone['notifications'] = Boolean(this.notification)
    },

    toggleAirplaneModeLocally () {
      this.toggleAirplane()
      this.bottone['airplane'] = Boolean(this.airplane)
    },

    resetPhone: function (param, data) {
      if (data.value !== 'cancel') {
        this.ignoreControls = true
        let scelte = [{
          title: this.LangString('APP_CONFIG_RESET_CONFIRM'),
          color: 'red',
          icons: 'fa-exclamation-triangle',
          reset: true
        }, {
          title: this.LangString('CANCEL'),
          icons: 'fa-undo',
          color: 'red'
        }]
        Modal.CreateModal({ scelte: scelte }).then(reponse => {
          this.ignoreControls = false
          if (reponse.reset === true) {
            this.$phoneAPI.deleteALL()
          }
        })
      }
    }
  },

  created () {
    // qui mi controllo i valori dei bottoni presi dai getters
    // in phone.js
    this.bottone['notifications'] = Boolean(this.notification)
    this.bottone['airplane'] = Boolean(this.airplane)
    this.bottone['bluetooth'] = Boolean(this.bluetooth)
    // qui richiedo le mie cover da phoneapi
    this.$phoneAPI.requestMyCovers()
    // console.log(JSON.stringify(this.myCovers))
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
  },
  mounted () { },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
  }
}
</script>

<style scoped>
.element {
  background-color: white;
  border-bottom: 1px solid rgb(223, 223, 223);
  height: 46px;
  line-height: 58px;
  display: flex;
  align-items: center;
  position: relative;
}

.element .fa {
  color: #002853;
  margin-left: 6px;
  height: 52px;
  width: 52px;
  text-align: center;
  line-height: 52px;
}

.element-content {
  display: block;
  height: 58px;
  width: 100%;
  margin-bottom: 10px;
  margin-left: 6px;
  display: flex;
  flex-flow: column;
  justify-content: center;
}

.element-title {
  display: block;
  margin-top: 6px;
  height: 22px;
  line-height: 22px;
  font-size: 15px;
  font-weight: bolder;
}

.element-value {
  display: block;
  line-height: 13px;
  height: 8px;
  padding-left: 5px;
  font-size: 12px;
  font-weight: 300;
  color: #808080;
}

.element.select {
  background-color: rgb(235, 235, 235);
}

.infoContainer {
  width: 100%;
  height: 180px;
}

.whiteContainer {
  position: relative;
  top: 20px;
  width: 100%;
  height: 90px;
  background-color: white;
}

.immagine {
  border-radius: 50%;
  position: relative;
  object-fit: cover;
  width: 20%;
  height: 73%;
  left: 20px;
  top: 12px;
}

.picText_label {
  position: relative;
  bottom: 26px;
  left: 24px;
  font-weight: bolder;
  color: rgb(0, 0, 0);
}

.picText_value {
  position: absolute;
  bottom: 23px;
  left: 102px;
  font-size: 15px;
  color: rgb(80, 80, 80);
}

.rightArrow {
  color: black;
  justify-content: right;
  position: absolute;
  right: 20px;
  top: 15px;
}

.switchDiv {
  position: absolute;
  left: 82%;
  bottom: 18%;
  overflow-y: hidden;
}

</style>
