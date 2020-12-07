<template>
  <div style="width: 326px; height: 743px;" class="sfondo">
    <PhoneTitle :title="this.gruppo.gruppo" :backgroundColor="'rgba(255,255,255,2)'" @back="onBackspace"/>

    <div v-for="(s, i) of messages" :key="i" class="whatsapp-menu-item">

      <div style="height: 20px;">
        <div v-if="isSentByMe(s)" class="bubble daMe" :class="{select: i === currentSelected}">{{s.sender}}: {{s.message}}</div>
        <div v-else class="bubble daAltri" :class="{select: i === currentSelected}">{{s.sender}}: {{s.message}}</div>
      </div>
      
    </div>

    <div style="width: 306px; bottom: 0px;" id='sms_write' @contextmenu.prevent="showOptions">

      <input type="text" v-model="message" :placeholder="IntlString('APP_WHATSAPP_PLACEHOLDER_ENTER_MESSAGE')" v-autofocus>
      
      <div style="font-size: 10px;" class="sms_send" @click.stop="send">

        <svg height="24" viewBox="0 0 24 24" width="24" @click.stop="send">
          <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
          <path d="M0 0h24v24H0z" fill="none"/>
        </svg>

      </div>

    </div>

  </div>
</template>


<script>
import { mapGetters, mapActions } from 'vuex'
import PhoneTitle from './../PhoneTitle'
import Modal from '@/components/Modal/index.js'

export default {
  components: { PhoneTitle },
  data () {
    return {
      currentSelected: -1,
      ignoreControls: false,
      gruppo: [],
      message: '',
      messages: []
    }
  },
  computed: {
    ...mapGetters(['IntlString', 'messaggi', 'myPhoneNumber', 'enableTakePhoto'])
  },
  methods: {
    ...mapActions(['requestWhatsappInfo', 'sendMessageInGroup']),
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
        this.selectMessage = 0
      } else {
        this.currentSelected = this.currentSelected === 0 ? 0 : this.currentSelected - 1
      }
      this.scrollIntoViewIfNeeded()
    },
    onDown () {
      if (this.ignoreControls === true) return
      if (this.currentSelected === -1) {
        this.currentSelected = 0
      } else {
        this.currentSelected = this.currentSelected === this.messaggi[this.gruppo.id].length - 1 ? this.currentSelected : this.currentSelected + 1
      }
      this.scrollIntoViewIfNeeded()
    },
    onBackspace () {
      if (this.ignoreControls === true) { this.ignoreControls = false; return }
      if (this.currentSelected !== -1) { this.currentSelected = -1; return }
      this.$router.push({ name: 'whatsapp' })
    },
    async onRight () {
      if (this.ignoreControls === true) return
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
            this.sendMessageInGroup({gruppo: this.gruppo, message: '%pos%', phoneNumber: this.myPhoneNumber})
            break
          case 2:
            this.ignoreControls = false
            const { url } = await this.$phoneAPI.takePhoto()
            if (url !== null && url !== undefined) { this.sendMessageInGroup({gruppo: this.gruppo, message: url, phoneNumber: this.myPhoneNumber}) }
            break
        }
      } catch (e) {} finally { this.ignoreControls = false }
    },
    onEnter () {
      if (this.ignoreControls === true) return
      if (this.currentSelected === -1) {
        this.$phoneAPI.getReponseText().then(data => {
          let message = data.text.trim()
          if (message !== '') {
            this.sendMessageInGroup({gruppo: this.gruppo, message: message, phoneNumber: this.myPhoneNumber})
          }
        })
      }
    },
    isSentByMe (messaggio) {
      if (messaggio.sender === this.myPhoneNumber) return true
      return false
    }
  },
  created () {
    this.requestWhatsappInfo(this.gruppo.id)
    this.gruppo = this.$route.params.gruppo
    if (this.messaggi[String(this.gruppo.id)] !== null || this.messaggi[String(this.gruppo.id)] !== undefined) { this.messages = this.messaggi[String(this.gruppo.id)] }
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
.generale {
  width: 326px; 
  height: 743px;
}

.sfondo {
  background-image: url("/html/static/img/app_whatsapp/sfondogruppi.png");
  background-repeat: no-repeat;
  width: auto;
  height: auto;
  margin: 0;
  padding: 0;
}

.whatsapp-menu-item {
  flex-grow: 1;
  flex-basis: 0;
  height: auto;
}

/* Input message zone */

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

.daAltri.select { background-color: rgb(118, 255, 137); }
.daAltri.select::before { background-color: rgb(118, 255, 137); }

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
