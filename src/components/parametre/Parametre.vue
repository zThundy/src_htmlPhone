<template>
  <div class="phone_app">
    <PhoneTitle :title="IntlString('APP_CONFIG_TITLE')" @back="onBackspace"/>

    <div class='phone_content elements'>
      <div class='element'
        v-for='(elem, key) in paramList' 
        v-bind:class="{ select: key === currentSelect}"
        v-bind:key="key"
      >

        <i class="fa" v-bind:class="elem.icons" v-bind:style="{color: elem.color}" @click.stop="onPressItem(key)"></i>

        <div class="element-content">
          <span class="element-title">{{elem.title}}</span>
          <span v-if="elem.value" class="element-value">{{elem.value}}</span>
        </div>
      </div>

    </div>
    
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import PhoneTitle from './../PhoneTitle'
import Modal from '@/components/Modal/index.js'
import PhoneAPI from './../../PhoneAPI'

export default {
  components: { PhoneTitle },
  data () {
    return {
      ignoreControls: false,
      currentSelect: 0,
      retiWifiRender: []
    }
  },
  computed: {
    ...mapGetters(['IntlString', 'myPhoneNumber', 'backgroundLabel', 'coqueLabel', 'sonidoLabel', 'zoom', 'config', 'volume', 'availableLanguages', 'wifiString', 'retiWifi', 'notification']),
    paramList () {
      // stringa di conferma reset
      const confirmResetStr = this.IntlString('APP_CONFIG_RESET_CONFIRM')
      const confirmReset = {}
      confirmReset[confirmResetStr] = {value: 'accept', icons: 'fa-exclamation-triangle'}
      // stringa di annulla
      const cancelStr = this.IntlString('CANCEL')
      const cancelTB = {}
      cancelTB[cancelStr] = {value: 'cancel', icons: 'fa-undo', color: 'red'}
      return [
        {
          icons: 'fa-phone',
          title: this.IntlString('APP_CONFIG_MY_MUNBER'),
          value: this.myPhoneNumber
        },
        {
          meta: 'wifi',
          icons: 'fa-wifi',
          onValid: 'connectToWifi',
          title: this.IntlString('APP_CONFIG_WIFI'),
          value: this.wifiString,
          values: []
        },
        {
          icons: 'fa-bell',
          onValid: 'toggleNotifications',
          title: this.IntlString('APP_CONFIG_NOTIFICATION'),
          value: (this.notification) ? 'Attive' : 'Disattive'
        },
        {
          icons: 'fa-picture-o',
          title: this.IntlString('APP_CONFIG_WALLPAPER'),
          value: this.backgroundLabel,
          onValid: 'onChangeBackground',
          values: this.config.background
        },
        {
          icons: 'fa-mobile',
          title: this.IntlString('APP_CONFIG_CASE'),
          value: this.coqueLabel,
          onValid: 'onChangeCoque',
          values: this.config.coque
        },
        {
          icons: 'fa-bell-o',
          title: this.IntlString('APP_CONFIG_SOUND'),
          value: this.sonidoLabel,
          onValid: 'onChangeSonido',
          values: this.config.sonido
        },
        {
          icons: 'fa-search',
          title: this.IntlString('APP_CONFIG_ZOOM'),
          value: this.zoom,
          onValid: 'setZoom',
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
          title: this.IntlString('APP_CONFIG_VOLUME'),
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
        {
          icons: 'fa-globe',
          title: this.IntlString('APP_CONFIG_LANGUAGE'),
          onValid: 'onChangeLanguages',
          values: {
            ...this.availableLanguages,
            ...cancelTB
          }
        },
        {
          icons: 'fa-exclamation-triangle',
          color: '#ee3838',
          title: this.IntlString('APP_CONFIG_RESET'),
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
    ...mapActions(['getIntlString', 'setZoon', 'setBackground', 'setCoque', 'setSonido', 'setVolume', 'setLanguage', 'toggleNotifications', 'updateWifiString']),
    scrollIntoViewIfNeeded: function () {
      this.$nextTick(() => {
        document.querySelector('.select').scrollIntoViewIfNeeded()
      })
    },

    updateWifiTable () {
      for (var i in this.retiWifi) {
        this.retiWifiRender[this.retiWifi[i].label] = {id: i, icons: 'fa-wifi', label: this.retiWifi[i].label, value: this.retiWifi[i].password}
      }
      this.retiWifiRender['Annulla'] = {icons: 'fa-undo', label: 'Annulla', value: 'cancel', color: 'red'}
      return this.retiWifiRender
    },

    onBackspace () {
      if (this.ignoreControls === true) return
      this.$router.push({ name: 'home' })
    },

    onUp: function () {
      if (this.ignoreControls === true) return
      this.currentSelect = this.currentSelect === 0 ? 0 : this.currentSelect - 1
      this.scrollIntoViewIfNeeded()
    },

    onDown: function () {
      if (this.ignoreControls === true) return
      this.currentSelect = this.currentSelect === this.paramList.length - 1 ? this.currentSelect : this.currentSelect + 1
      this.scrollIntoViewIfNeeded()
    },

    onRight () {
      if (this.ignoreControls === true) return
      let param = this.paramList[this.currentSelect]
      if (param.onRight !== undefined) {
        param.onRight(param)
      }
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
        let choix = Object.keys(param.values).map(key => {
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
        Modal.CreateModal({choix}).then(reponse => {
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

    onPressItem (index) {
      this.actionItem(this.paramList[index])
    },

    onEnter () {
      if (this.ignoreControls === true) return
      if (this.paramList[this.currentSelect].meta !== undefined && this.paramList[this.currentSelect].meta === 'wifi') {
        this.paramList[this.currentSelect].values = this.updateWifiTable()
      }
      this.actionItem(this.paramList[this.currentSelect])
    },

    async onChangeBackground (param, data) {
      let val = data.value
      if (val === 'Link') {
        this.ignoreControls = true
        let choix = [
          {id: 1, title: this.IntlString('APP_CONFIG_LINK_PICTURE'), icons: 'fa-link'},
          {id: 2, title: this.IntlString('APP_CONFIG_TAKE_PICTURE'), icons: 'fa-camera'}
        ]
        const resp = await Modal.CreateModal({ choix: choix })
        if (resp.id === 1) {
          Modal.CreateTextModal({ text: 'https://i.imgur.com/' }).then(valueText => {
            if (valueText.text !== '' && valueText.text !== undefined && valueText.text !== null && valueText.text !== 'https://i.imgur.com/') {
              this.setBackground({
                label: 'Personalizzato',
                value: valueText.text
              })
              this.ignoreControls = false
            }
          })
        } else if (resp.id === 2) {
          const newAvatar = await PhoneAPI.takePhoto()
          if (newAvatar.url !== null) {
            this.setBackground({
              label: 'Personalizzato',
              value: newAvatar.url
            })
            this.ignoreControls = false
          }
        } else {
          this.ignoreControls = false
        }
      } else {
        this.setBackground({
          label: data.title,
          value: data.value
        })
        this.ignoreControls = false
      }
    },

    async connectToWifi (param, data) {
      var password = data.value
      this.ignoreControls = true
      Modal.CreateTextModal({ text: '' }).then(valueText => {
        if (valueText.text !== '' && valueText.text !== undefined && valueText.text !== null) {
          if (valueText.text === password) {
            // console.log('hey ai azzecato! :P')
            PhoneAPI.connettiAllaRete(this.retiWifiRender[data.title])
            this.updateWifiString(true)
            this.ignoreControls = false
          } else {
            // console.log('no azzecato :(')
            PhoneAPI.connettiAllaRete(false)
            this.updateWifiString(false)
            this.ignoreControls = false
          }
        }
      })
    },

    onChangeCoque: function (param, data) {
      this.setCoque({
        label: data.title,
        value: data.value
      })
    },

    onChangeSonido: function (param, data) {
      this.setSonido({
        label: data.title,
        value: data.value
      })
    },

    setZoom: function (param, data) {
      this.setZoon(data.value)
    },

    ajustZoom (inc) {
      return () => {
        const percent = Math.max(10, (parseInt(this.zoom) || 100) + inc)
        this.setZoon(`${percent}%`)
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

    resetPhone: function (param, data) {
      if (data.value !== 'cancel') {
        this.ignoreControls = true
        let choix = [{
          title: this.IntlString('APP_CONFIG_RESET_CONFIRM'),
          color: 'red',
          icons: 'fa-exclamation-triangle',
          reset: true
        }, {
          title: this.IntlString('CANCEL'),
          icons: 'fa-undo'
        }]
        Modal.CreateModal({ choix: choix }).then(reponse => {
          this.ignoreControls = false
          if (reponse.reset === true) {
            this.$phoneAPI.deleteALL()
          }
        })
      }
    }
  },

  created () {
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
  },
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
.element{
  height: 58px;
  line-height: 58px;
  display: flex;
  align-items: center;
  position: relative;
}
.element .fa{
  color: #0b81ff;
  margin-left: 6px;
  height: 52px;
  width: 52px;
  text-align: center;
  line-height: 52px;
}
.element-content{
  display: block;
  height: 58px;
  width: 100%;
  margin-left: 6px;
  display: flex;
  flex-flow: column;
  justify-content: center;
}
.element-title{
  display: block;
  margin-top: 4px;
  height: 22px;
  line-height: 22px;
  font-size: 20px;
  font-weight: 300;
  font-family: -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;
}
.element-value{
  display: block;
  line-height: 16px;
  height: 8px;
  font-size: 14px;
  font-weight: 100;
  color: #808080;
}
.element.select, .element:hover{
   background-color: #DDD;
}
</style>
