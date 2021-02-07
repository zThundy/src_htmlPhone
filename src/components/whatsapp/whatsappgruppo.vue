<template>
  <div style="width: 326px; height: 743px;" class="sfondo">
    <PhoneTitle :title="this.gruppo.gruppo" :titleColor="'black'" :backgroundColor="'rgb(112,255,125)'" @back="onBackspace"/>

    <div class="groupImage" data-type="button">
      <img :src="gruppo.icona" />
    </div>

    <div class="phone_fullscreen_img" v-if="imgZoom !== undefined">
      <img :src="imgZoom" />
    </div>

    <md-toast ref="wh_update">
      <custom-toast @hide="toastHide" :duration="4000" ref="updating">
        <md-activity-indicator
          :size="20"
          :text-size="16"
          color="white"
          text-color="white"
        >Aggiornamento...
        </md-activity-indicator>
      </custom-toast>
    </md-toast>

    <div style="width: 326px; height: 575px;" id='sms_list'>

      <div v-for="(s, i) of messaggi[String(gruppo.id)]" :key="i" v-bind:class="{select: i === currentSelected}" class="whatsapp-menu-item">

        <div v-if="!isImage(s)" style="overflow: auto;">
          <div v-if="isSentByMe(s)" class="bubble daMe" :class="{select: i === currentSelected}">{{s.sender}}: {{s.message}}</div>
          <div v-else class="bubble daAltri" :class="{select: i === currentSelected}">{{s.sender}}: {{s.message}}</div>
        </div>

        <div v-else style="overflow: auto;">
          <img v-if="isSentByMe(s)" class="sms-img bubble daMe" :class="{select: i === currentSelected}" :src="s.message">
          <img v-else class="sms-img bubble daAltri" :class="{select: i === currentSelected}" :src="s.message">
        </div>
        
      </div>

    </div>

    <div style="height: 70px; position: fixed;">
      <div style="width: 306px;" id='sms_write'>
        <input type="text" :placeholder="IntlString('APP_WHATSAPP_PLACEHOLDER_ENTER_MESSAGE')" v-autofocus>
        <div style="font-size: 10px;" class="sms_send">
          <svg height="24" viewBox="0 0 24 24" width="24">
            <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
            <path d="M0 0h24v24H0z" fill="none"/>
          </svg>
        </div>
      </div>
    </div>

  </div>
</template>


<script>
import { mapGetters, mapActions, mapMutations } from 'vuex'

import { ActivityIndicator } from 'mand-mobile'
import 'mand-mobile/lib/mand-mobile.css'

import CustomToast from '@/components/CustomToast'
import Modal from '@/components/Modal/index.js'
import PhoneTitle from './../PhoneTitle'

export default {
  name: 'whatsapp_selected_group',
  components: {
    PhoneTitle,
    CustomToast,
    [ActivityIndicator.name]: ActivityIndicator
  },
  data () {
    return {
      currentSelected: -1,
      ignoreControls: false,
      gruppo: [],
      imgZoom: undefined
    }
  },
  computed: {
    ...mapGetters(['IntlString', 'messaggi', 'myPhoneNumber', 'enableTakePhoto', 'contacts'])
  },
  methods: {
    ...mapActions(['requestWhatsappInfo', 'sendMessageInGroup']),
    ...mapMutations(['CHANGE_BRIGHTNESS_STATE']),
    scrollIntoViewIfNeeded () {
      this.$nextTick(() => {
        const elem = this.$el.querySelector('.select')
        if (elem !== null) {
          elem.scrollIntoViewIfNeeded()
        }
      })
    },
    onUp () {
      if (this.ignoreControls === true) return
      if (this.currentSelected === -1) {
        this.currentSelected = this.messaggi[String(this.gruppo.id)].length - 1
      } else {
        this.currentSelected = this.currentSelected === 0 ? 0 : this.currentSelected - 1
      }
      this.scrollIntoViewIfNeeded()
    },
    onDown () {
      if (this.ignoreControls === true) return
      if (this.currentSelected === -1) {
        this.currentSelected = this.messaggi[String(this.gruppo.id)].length - 1
      } else {
        this.currentSelected = this.currentSelected === this.messaggi[this.gruppo.id].length - 1 ? this.currentSelected : this.currentSelected + 1
      }
      this.scrollIntoViewIfNeeded()
    },
    onBackspace () {
      if (this.imgZoom !== undefined) {
        this.imgZoom = undefined
        this.CHANGE_BRIGHTNESS_STATE(true)
        return
      }
      if (this.ignoreControls === true) { this.ignoreControls = false; return }
      if (this.currentSelected !== -1) { this.currentSelected = -1; return }
      this.$router.push({ name: 'whatsapp' })
    },
    async onRight () {
      if (this.ignoreControls === true) return
      // qui controllo se hai un messaggio selezionato
      // così da farti uscire le impostazioni di quel messaggio
      // oppure della chat
      if (this.currentSelected === -1) {
        try {
          this.ignoreControls = true
          let choix = [
            {id: 1, title: this.IntlString('APP_WHATSAPP_SEND_GPS'), icons: 'fa-location-arrow'},
            {id: -1, title: this.IntlString('CANCEL'), icons: 'fa-undo', color: 'red'}
          ]
          if (this.enableTakePhoto) {
            choix = [
              {id: 1, title: this.IntlString('APP_WHATSAPP_SEND_GPS'), icons: 'fa-location-arrow'},
              {id: 2, title: this.IntlString('APP_WHATSAPP_SEND_PHOTO'), icons: 'fa-picture-o'},
              {id: -1, title: this.IntlString('CANCEL'), icons: 'fa-undo', color: 'red'}
            ]
          }
          const resp = await Modal.CreateModal({ choix })
          switch (resp.id) {
            case 1:
              this.ignoreControls = false
              if (this.myPhoneNumber.includes('#') || this.myPhoneNumber === 0 || this.myPhoneNumber === '0') {
                this.$phoneAPI.onwhatsapp_showError({ title: 'Errore', message: 'Impossibile ottenere il numero di telefono' })
              } else {
                this.sendMessageInGroup({ gruppo: this.gruppo, message: '%pos%', phoneNumber: this.myPhoneNumber })
              }
              break
            case 2:
              this.ignoreControls = false
              const { url } = await this.$phoneAPI.takePhoto()
              if (url !== null && url !== undefined) { this.sendMessageInGroup({ gruppo: this.gruppo, message: url, phoneNumber: this.myPhoneNumber }) }
              break
          }
        } catch (e) {} finally { this.ignoreControls = false }
      } else {
        this.onActionMessage(this.messaggi[String(this.gruppo.id)][this.currentSelected])
      }
    },
    isImage (mess) {
      return /^https?:\/\/.*\.(png|jpg|jpeg|gif)/.test(mess.message)
    },
    onEnter () {
      if (this.ignoreControls === true) return
      this.$phoneAPI.getReponseText({ title: 'Invia un messaggio' }).then(data => {
        let message = data.text.trim()
        if (message !== '') {
          if (this.myPhoneNumber.includes('#') || this.myPhoneNumber === 0 || this.myPhoneNumber === '0') {
            this.$phoneAPI.onwhatsapp_showError({ title: 'Errore', message: 'Impossibile ottenere il numero di telefono' })
          } else {
            this.sendMessageInGroup({ gruppo: this.gruppo, message: message, phoneNumber: this.myPhoneNumber })
          }
          // qui aggiorno la visualizzazione dei messaggi
          setTimeout(() => {
            this.currentSelected = this.messaggi[String(this.gruppo.id)].length - 1
            this.scrollIntoViewIfNeeded()
          }, 200)
        }
      })
    },
    isSentByMe (messaggio) {
      if (messaggio.sender === this.myPhoneNumber) return true
      return false
    },
    async onActionMessage (message) {
      try {
        let isGPS = /(-?\d+(\.\d+)?), (-?\d+(\.\d+)?)/.test(message.message)
        let isSMSImage = this.isImage(message)
        // dopo aver controllato che tipo di messaggio è, creo il modal
        let choix = [
          { id: 1, title: this.IntlString('APP_WHATSAPP_SEND_GPS'), icons: 'fa-location-arrow' },
          { id: 2, title: this.IntlString('APP_WHATSAPP_SEND_PHOTO'), icons: 'fa-picture-o' },
          { id: -1, title: this.IntlString('CANCEL'), icons: 'fa-undo', color: 'red' }
        ]
        if (isGPS === true) { choix = [{ id: 'gps', title: this.IntlString('APP_WHATSAPP_SET_GPS'), icons: 'fa-location-arrow' }, ...choix] }
        if (isSMSImage === true) { choix = [{ id: 'zoom', title: this.IntlString('APP_MESSAGE_ZOOM_IMG'), icons: 'fa-search' }, ...choix] }
        // disabilito i controlli
        this.ignoreControls = true
        const data = await Modal.CreateModal({ choix })
        if (data.id === 'gps') {
          let val = message.message.match(/(-?\d+(\.\d+)?), (-?\d+(\.\d+)?)/)
          this.$phoneAPI.setGPS(val[1], val[3])
        } else if (data.id === 'zoom') {
          this.CHANGE_BRIGHTNESS_STATE(false)
          this.imgZoom = message.message
        } else if (data.id === 1) {
          this.ignoreControls = false
          if (this.myPhoneNumber.includes('#') || this.myPhoneNumber === 0 || this.myPhoneNumber === '0') {
            this.$phoneAPI.onwhatsapp_showError({ title: 'Errore', message: 'Impossibile ottenere il numero di telefono' })
          } else {
            this.sendMessageInGroup({ gruppo: this.gruppo, message: '%pos%', phoneNumber: this.myPhoneNumber })
          }
        } else if (data.id === 2) {
          this.ignoreControls = false
          const pic = await this.$phoneAPI.takePhoto()
          if (pic !== null && pic !== undefined) { this.sendMessageInGroup({ gruppo: this.gruppo, message: pic.url, phoneNumber: this.myPhoneNumber }) }
        }
      } catch (e) { } finally { this.ignoreControls = false }
    },
    async startUpdatingMessages () {
      this.$refs.updating.show()
      this.ignoreControls = true
      setTimeout(() => {
        this.currentSelected = this.messaggi[String(this.gruppo.id)].length - 1
        this.scrollIntoViewIfNeeded()
        this.ignoreControls = false
      }, 1000)
    }
  },
  created () {
    if (this.$route.params.updategroups) { this.$phoneAPI.requestInfoOfGroups() }
    this.gruppo = this.$route.params.gruppo
    this.requestWhatsappInfo({ groupId: this.gruppo.id, contacts: this.contacts })
    // qui imposto il messaggio all'ultimo e con la funzione
    // lo "metto in mostra"
    setTimeout(() => {
      this.startUpdatingMessages()
    }, 100)
    // eventi attivi //
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpEnter', this.onEnter)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpEnter', this.onEnter)
  }
}
</script>

<style scoped>
.sfondo {
  background-image: url("/html/static/img/app_whatsapp/sfondogruppi.png");
  background-repeat: no-repeat;
  width: auto;
  height: auto;
  margin: 0;
  padding: 0;
  position: absolute;
}

.whatsapp-menu-item {
  flex-grow: 1;
  flex-basis: 0;
  height: auto;
}

/* Input message zone */

#sms_list{
    height: calc(100% - 34px - 26px);
    overflow-y: auto;
    padding-bottom: 8px;
}

#sms_write {
  position: absolute;
  height: 56px;
  margin: 10px;
  width: 380px;
  background-color: #e9e9eb;
  border-radius: 56px;
  padding-bottom: 0px;
}

#sms_write input {
  height: 56px;
  border: none;
  outline: none;
  font-size: 16px;
  margin-left: 14px;
  padding: 12px 5px;
  background-color: rgba(236, 236, 241, 0)
}

.sms_send {
  float: right;
  margin-right: 10px;
}

.sms_send svg{
  margin: 8px; 
  width: 36px;
  height: 36px;
  fill: #C0C0C0;
}

.sms-img{
  width: 80%;
  height: auto;
  padding-top: 12px;
  border-radius: 19px;
}

/* IMMAGINE DEL GRUPPO */

.groupImage {
  position: inherit;
  
  top: 35px;
  right: 15px;
}

.groupImage img {
  object-fit: cover;

  border-radius: 50%;
  border-style: solid;
  border-color: rgb(6, 75, 0);

  height: 50px;
  width: 50px;
}








/* css bolle dei messaggi */

.bubble {
  background-color: #F2F2F2;
  border-radius: 5px;
  box-shadow: 0 0 7px #868686;
  display: inline-block;
  padding: 10px 18px;
  position: relative;
  vertical-align: top;
}

.bubble::before {
  background-color: #F2F2F2;
  content: "\00a0";
  display: block;
  height: 16px;
  position: absolute;
  top: 11px;
  transform:             rotate( 29deg ) skew( -35deg );
      -moz-transform:    rotate( 29deg ) skew( -35deg );
      -ms-transform:     rotate( 29deg ) skew( -35deg );
      -o-transform:      rotate( 29deg ) skew( -35deg );
      -webkit-transform: rotate( 29deg ) skew( -35deg );
  width:  20px;
}

.daAltri {
  float: left;
  margin: 5px 45px 5px 20px;
}

.daAltri::before {
  box-shadow: -2px 2px 2px 0 rgba( 178, 178, 178, .4 );
  left: -9px;
}

.daAltri.select { background-color: rgb(230, 230, 230); }
.daAltri.select::before { background-color: rgb(230, 230, 230); }

.daMe {
  float: right;
  margin: 5px 20px 5px 45px;
  background-color: rgb(162, 255, 175);     
}

.daMe::before {
  box-shadow: 2px -2px 2px 0 rgba( 178, 178, 178, .4 );
  right: -9px;
  background-color: rgb(162, 255, 175); 
}

.daMe.select { background-color: rgb(118, 255, 137); }
.daMe.select::before { background-color: rgb(118, 255, 137); }


</style>
