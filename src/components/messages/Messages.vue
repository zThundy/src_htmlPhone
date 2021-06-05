<template>
<!--ESTE HTML ES ACOPLADO DEL VIEJO--> 
  <div style="backgroundColor: white" class="phone_app messages">
    <PhoneTitle :backgroundColor="'rgb(194, 108, 7)'" :title="formatEmoji(displayContact)" style="color: black" @back="quit"/> <!--:title="displayContact" :backgroundColor="color" -->
    
    <div class="phone_fullscreen_img" v-if="imgZoom !== undefined">
      <img :src="imgZoom" />
    </div>

    <!-- <textarea ref="copyTextarea" class="copyTextarea"/> -->
    
    <div id='sms_list'>
      <div style="position: absolute;" class="groupImage" data-type="button">
        <img v-if="isSMSImage(getContactIcon())" :src="getContactIcon()"/>
      </div>

      <div class="sms" v-bind:class="{ select: key === selectMessage }" v-for='(mess, key) in messagesListApp' v-bind:key="mess.id">
        <div class="sms_message_time">
          <!-- <h6 v-bind:class="{ sms_me : mess.owner === 1 }" class="name_other_sms_me">{{ displayContact }}</h6> -->
          <h6 v-bind:class="{ sms_me : mess.owner === 1 }" class="name_other_sms_other"><timeago class="sms_time" :since='mess.time' :auto-update="20"></timeago></h6>
        </div>

        <span class='sms_message sms_me' v-bind:class="{ sms_other : mess.owner === 0 }">
          <img v-if="isSMSImage(mess.message)" class="sms-img" :src="mess.message"/>
          <div class="contact-forward-container" v-else-if="isSMSContact(mess.message)">
            <div class="contact-forward-background">
              <div class="contact-forward-pic" :style="stylePuce(mess)">{{ getSMSContactInfo(mess.message).letter }}</div>
              <!-- <img class="contact-forward-pic" :src="getSMSContactInfo(mess.message).pic"> -->
              <div class="contact-forward-info-container">
                <span class="contact-forward-number">{{ getSMSContactInfo(mess.message).number }}</span>
                <span class="contact-forward-name">{{ formatEmoji(getSMSContactInfo(mess.message).name) }}</span>
              </div>
            </div>
            <div class="contact-forward-buttons-container">
              <div style="border-right: 1px solid grey;" class="contact-forward-button">
                <span class="contact-forward-button-text">{{ LangString("APP_MESSAGE_FORWARDED_CONTACT_ADD") }}</span>
              </div>
              <div class="contact-forward-button">
                <span class="contact-forward-button-text">{{ LangString("APP_MESSAGE_FORWARDED_CONTACT_MESSAGE") }}</span>
              </div>
            </div>
          </div>
          <!--
            <div v-if="mess.message.includes('%CONTACT%')">
              {{ mess.message.split(':').pop() }}
              <input type="button" :value="LangString('APP_MESSAGES_ADD_CONTACT')">
            </div>
          -->
          <span v-else class="sms_message">{{ formatEmoji(mess.message) }}</span>
            <!-- <span style="color: white; font-size: 17px; margin: 24px;" @click.stop="onActionMessage(mess)"><timeago class="sms_time" :since='mess.time' :auto-update="20"></timeago></span> -->
        </span>

      </div>
    </div>

    <div style="width: 306px;" id='sms_write'>
      <input type="text" v-model="message" :placeholder="LangString('APP_MESSAGE_PLACEHOLDER_ENTER_MESSAGE')">
      <div class="sms_send">
        <svg height="24" viewBox="0 0 24 24" width="24">
          <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
          <path d="M0 0h24v24H0z" fill="none"/>
        </svg>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions, mapMutations } from 'vuex'
import { generateColorForStr, getBestFontColor } from './../../Utils'
import PhoneTitle from './../PhoneTitle'
import Modal from '@/components/Modal/index.js'

export default {
  data () {
    return {
      ignoreControls: false,
      selectMessage: -1,
      display: '',
      phoneNumber: '',
      imgZoom: undefined,
      message: '',
      letter: ''
    }
  },
  components: { PhoneTitle },
  methods: {
    ...mapActions(['setMessageRead', 'sendMessage', 'deleteMessage', 'startCall']),
    ...mapMutations(['CHANGE_BRIGHTNESS_STATE']),
    formatEmoji (message) {
      return this.$phoneAPI.convertEmoji(message)
    },
    resetScroll () {
      this.$nextTick(() => {
        let elem = document.querySelector('#sms_list')
        elem.scrollTop = elem.scrollHeight
        this.selectMessage = -1
      })
    },
    scrollIntoView () {
      this.$nextTick(() => {
        const elem = this.$el.querySelector('.select')
        if (elem !== null) {
          elem.scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' })
        }
      })
    },
    quit () {
      // this.$router.push({path: '/messages'})
      this.$router.go(-1)
    },
    onUp () {
      if (this.ignoreControls === true) return
      if (this.selectMessage === -1) {
        this.selectMessage = this.messagesListApp.length - 1
      } else {
        this.selectMessage = this.selectMessage === 0 ? 0 : this.selectMessage - 1
      }
      this.scrollIntoView()
    },
    onDown () {
      if (this.ignoreControls === true) return
      if (this.selectMessage === -1) {
        this.selectMessage = this.messagesListApp.length - 1
      } else {
        this.selectMessage = this.selectMessage === this.messagesListApp.length - 1 ? this.selectMessage : this.selectMessage + 1
      }
      this.scrollIntoView()
    },
    onEnter () {
      if (this.ignoreControls === true) return
      if (this.selectMessage !== -1) {
        this.onActionMessage(this.messagesListApp[this.selectMessage])
      } else {
        this.$phoneAPI.getReponseText({ title: 'Digita il messaggio' }).then(data => {
          let message = data.text.trim()
          if (message !== '') {
            this.sendMessage({ phoneNumber: this.phoneNumber, message })
          }
        })
      }
    },
    send () {
      const message = this.message.trim()
      if (message === '') return
      this.message = ''
      this.sendMessage({ phoneNumber: this.phoneNumber, message })
    },
    isSMSImage (mess) {
      var pattern = new RegExp('^(https?:\\/\\/)?' + '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|' + '((\\d{1,3}\\.){3}\\d{1,3}))' + '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*' + '(\\?[;&a-z\\d%_.~+=-]*)?' + '(\\#[-a-z\\d_]*)?$', 'i')
      return !!pattern.test(mess)
    },
    isSMSContact (mess) {
      // console.log(mess.indexOf('%CONTACT%'))
      // console.log(mess)
      return mess.indexOf('[CONTACT]') === 0
    },
    getSMSContactInfo (mess) {
      var obj = mess.split('%')
      // console.log(obj[2])
      // if (obj[4] === '' || obj[4] === undefined) {
      //   obj[4] === null
      // }
      return {
        name: obj[2],
        number: obj[1],
        email: obj[3],
        icon: obj[4],
        letter: obj[2][0]
      }
    },
    stylePuce (data) {
      data = data || {}
      // console.log(data)
      data.icon = this.getSMSContactInfo(data.message).icon
      // console.log(data.icon)
      if (data.icon !== 'undefined' && data.icon !== undefined && data.icon !== null && data.icon !== '') {
        return {
          backgroundImage: `url(${data.icon})`,
          'background-position': 'center',
          backgroundSize: 'cover',
          color: 'rgba(0,0,0,0)',
          borderRadius: '50%',
          'object-fit': 'fill'
        }
      }
      return {
        color: 'black',
        backgroundColor: this.color,
        borderRadius: '50%'
      }
    },
    getContactIcon () {
      for (var key in this.contacts) {
        if (this.contacts[key].number === this.phoneNumber) {
          if (this.contacts[key].icon !== undefined && this.contacts[key].icon !== null) {
            return this.contacts[key].icon
          } else {
            this.letter = this.display.charAt(0)
            return {
              backgroundColor: this.color
            }
          }
        }
      }
    },
    async onActionMessage (message) {
      try {
        // let message = this.messagesListApp[this.selectMessage]
        let isGPS = /(-?\d+(\.\d+)?), (-?\d+(\.\d+)?)/.test(message.message)
        let hasNumber = /#([0-9]+)/.test(message.message)
        let choix = [
          {
            id: 'inoltra',
            title: this.LangString('APP_MESSAGE_INOLTRA_IMG'),
            icons: 'fa-paper-plane'
          },
          {
            id: 'delete',
            title: this.LangString('APP_MESSAGE_DELETE'),
            icons: 'fa-trash'
          },
          {
            id: -1,
            title: this.LangString('CANCEL'),
            icons: 'fa-undo',
            color: 'red'
          }
        ]
        if (isGPS === true) {
          choix = [{
            id: 'gps',
            title: this.LangString('APP_MESSAGE_SET_GPS'),
            icons: 'fa-location-arrow'
          }, ...choix]
        }
        if (this.isSMSContact(message.message)) {
          choix = [{
            id: 'add_contact',
            title: this.LangString('APP_MESSAGE_ADD_CONTACT'),
            icons: 'fa-plus'
          }, ...choix]
          // {
          //   id: 'message_contact',
          //   title: this.LangString('APP_MESSAGE_MESSAGE_CONTACT'),
          //   icons: 'fa-comment'
          // }, ...choix]
        }
        if (hasNumber === true) {
          const num = message.message.match(/#([0-9-]*)/)[1]
          choix = [{
            id: 'num',
            title: `${this.LangString('APP_MESSAGE_MESS_NUMBER')} ${num}`,
            number: num,
            icons: 'fa-phone'
          }, ...choix]
        }
        if (this.isSMSImage(message.message)) {
          choix = [{
            id: 'zoom',
            title: this.LangString('APP_MESSAGE_ZOOM_IMG'),
            icons: 'fa-search'
          }, ...choix]
        }
        this.ignoreControls = true
        const data = await Modal.CreateModal({choix})
        if (data.id === 'delete') {
          this.deleteMessage({ id: message.id })
        } else if (data.id === 'gps') {
          let val = message.message.match(/(-?\d+(\.\d+)?), (-?\d+(\.\d+)?)/)
          this.$phoneAPI.setGPS(val[1], val[3])
        } else if (data.id === 'num') {
          this.$nextTick(() => {
            this.onSelectPhoneNumber(data.number)
          })
        } else if (data.id === 'zoom') {
          this.imgZoom = message.message
          this.CHANGE_BRIGHTNESS_STATE(false)
        } else if (data.id === 'inoltra') {
          this.$router.push({ name: 'messages.chooseinoltra', params: { message: message.message } })
          // this.sendMessage({ phoneNumber: this.phoneNumber, message })
        } else if (data.id === 'add_contact') {
          let c = this.getSMSContactInfo(message.message)
          this.$router.push({ name: 'contacts.view', params: { id: -1, isForwarded: true, number: c.number, display: c.name, email: c.email, icon: c.icon } })
        } else if (data.id === 'message_contact') {
          let c = this.getSMSContactInfo(message.message)
          this.$router.push({ name: 'messages.view', params: { number: c.number, display: c.name } })
        }
      } catch (e) {
        // console.log(e)
      } finally {
        this.ignoreControls = false
        this.selectMessage = -1
      }
    },
    async onSelectPhoneNumber (number) {
      try {
        this.ignoreControls = true
        let choix = [
          {
            id: 'sms',
            title: this.LangString('APP_MESSAGE_MESS_SMS'),
            icons: 'fa-comment'
          },
          {
            id: 'call',
            title: this.LangString('APP_MESSAGE_MESS_CALL'),
            icons: 'fa-phone'
          },
          {
            id: -1,
            title: this.LangString('CANCEL'),
            icons: 'fa-undo',
            color: 'red'
          }// ,
          // {
          //   id: 'copy',
          //   title: this.LangString('APP_MESSAGE_MESS_COPY'),
          //   icons: 'fa-copy'
          // }
        ]

        const data = await Modal.CreateModal({ choix })
        if (data.id === 'sms') {
          this.phoneNumber = number
          this.display = undefined
        } else if (data.id === 'call') {
          this.startCall({ numero: number })
        // } else if (data.id === 'copy') {
        //   try {
        //     const $copyTextarea = this.$refs.copyTextarea
        //     $copyTextarea.value = number
        //     $copyTextarea.style.height = '20px'
        //     $copyTextarea.focus()
        //     $copyTextarea.select()
        //     await document.execCommand('copy')
        //     $copyTextarea.style.height = '0'
        //   } catch (error) {
        //   }
        }
      } catch (e) {
      } finally {
        this.ignoreControls = false
        this.selectMessage = -1
      }
    },
    onBackspace () {
      if (this.imgZoom !== undefined) {
        this.imgZoom = undefined
        this.CHANGE_BRIGHTNESS_STATE(true)
        return
      }
      if (this.ignoreControls === true) return
      if (this.selectMessage !== -1) {
        this.selectMessage = -1
      } else {
        this.quit()
      }
    },
    onRight: function () {
      if (this.ignoreControls === true) return
      if (this.selectMessage === -1) {
        this.showOptions()
      }
    },
    async showOptions () {
      try {
        this.ignoreControls = true
        let choix = [
          {id: 1, title: this.LangString('APP_MESSAGE_SEND_GPS'), icons: 'fa-location-arrow'},
          {id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red'}
        ]
        if (this.enableTakePhoto) {
          choix = [
            {id: 1, title: this.LangString('APP_MESSAGE_SEND_GPS'), icons: 'fa-location-arrow'},
            {id: 2, title: this.LangString('APP_MESSAGE_SEND_PHOTO'), icons: 'fa-picture-o'},
            {id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red'}
          ]
        }
        const data = await Modal.CreateModal({ choix })
        if (data.id === 1) {
          this.sendMessage({ phoneNumber: this.phoneNumber, message: '%pos%' })
        }
        if (data.id === 2) {
          const { url } = await this.$phoneAPI.takePhoto()
          if (url !== null && url !== undefined) {
            this.sendMessage({ phoneNumber: this.phoneNumber, message: url })
          }
        }
        this.ignoreControls = false
      } catch (e) {
      } finally {
        this.ignoreControls = false
      }
    }
  },
  computed: {
    ...mapGetters(['LangString', 'messages', 'contacts', 'enableTakePhoto']),
    messagesListApp () {
      return this.messages.filter(e => e.transmitter === this.phoneNumber).sort((a, b) => a.time - b.time)
      // messages = messages.forEach(element => {
      //   element.message = this.$phoneAPI.convertEmoji(element.message)
      // })
      // return messages
    },
    displayContact () {
      if (this.display !== undefined) {
        return this.display
      }
      const c = this.contacts.find(c => c.number === this.phoneNumber)
      if (c !== undefined) {
        return c.display
      }
      return this.phoneNumber
    },
    color () {
      return generateColorForStr(this.phoneNumber)
    },
    colorSmsOwner () {
      return [
        {
          backgroundColor: this.color,
          color: getBestFontColor(this.color)
        }, {}
      ]
    }
  },
  watch: {
    messagesListApp () {
      this.setMessageRead(this.phoneNumber)
      this.resetScroll()
    }
  },
  created () {
    this.display = this.$route.params.display
    this.phoneNumber = this.$route.params.number
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
  }
}
</script>

<style scoped>
.messages {
  position: absolute;

  bottom: 0;
  left: 0;
  right: 0;

  width: 326px;
  height: 678px;
}

#sms_contact{
  background-color: #4CAF50;
  color: white;
  height: 34px;
  line-height: 34px;
  padding-left: 5px;
}

#sms_list{
  width: 326px;
  height: 678px;
  background-color: white;

  height: calc(100% - 34px - 26px);
  overflow: hidden;
  padding-bottom: 8px;
}

.name_other_sms_other {
  margin-bottom: -9px;
  margin-left: 42px;
  font-size: 14px;
  /* font-weight: 500; */
  color: lightgrey;
}

.name_other_sms_me {
  display: none;
}

.name_other_sms_other.sms_me {
  display: none;
}

.sms {
  font-weight: lighter;
  overflow: auto;
  zoom: 1;
}

.sms-img {
  width: 100%;
  height: 100%;
  margin-top: 10px;
  border-radius: 5px;
}

.sms_me {
  float: right;
  background-color: #e9e9eb;
  border-radius: 6px;
  padding: 5px 10px;
  max-width: 90%;
  margin-right: 5%;
  margin-top: 10px;
}

.sms_other {
  background-color: #0b81ff;
  border-radius: 6px;
  color:white;
  float: left;
  padding: 5px 10px;
  max-width: 90%;
  margin-left: 5%;
  margin-top: 10px;
}


.sms_time {
  display: block;
  font-size: 12px;
  font-weight: lighter;
}

.sms_me .sms_time {
  color: #AAA;
  margin-left: 4px;
  margin-top: -5px;
  display: none;
  font-size: 9px; 
}

.sms_other .sms_time {
  color: white;
  display: none;
  margin-left: 4px;
  margin-top: -5px;
  font-size: 9px;
}


.messages {
  position: relative;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
}

.sms.select .sms_message {
  background-color: rgb(0, 99, 204);
  color: #ffffff;
}

.sms_message {
  font-weight: lighter;
  word-wrap: break-word;
  max-width: 80%;
  font-size: 21px;
  padding-top: 0.1px;
}

#sms_write {
  height: 56px;
  margin: 10px;
  width: 380px;
  background-color: #e9e9eb;
  border-radius: 56px;
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
  font-size: 10px;
}

.sms_send svg {
  margin: 8px; 
  width: 36px;
  height: 36px;
  fill: #C0C0C0;
}

.copyTextarea {
  height: 0;
  border: 0;
  padding: 0;
}

.groupImage {
  top: 35.5px;
  right: 15.5px;
}

.groupImage img {
  object-fit: cover;
  border-radius: 50%;
  border: 2px solid rgb(0, 0, 0);

  height: 40px;
  width: 40px;

  overflow: hidden;
  display: flex;

  align-content: center;
  justify-content: center;
  align-items: center;
}

/* CONTACT FORWARD SECTION */
.contact-forward-container {
  width: 250px;
  height: 110px;
}

.contact-forward-background {
  border-radius: 5px;
  background-color: rgb(240, 240, 240);
  margin-top: 8px;
  width: 97%;
  height: 98%;
  display: flex;
  flex-direction: row;
  border: 1px solid grey;
  overflow: hidden;
}

.contact-forward-pic {
  margin-top: 5px;
  margin-left: 5px;
  height: 60px;
  width: 60px;
  border-radius: 50px;
  overflow: hidden;
  object-fit: cover;

  text-align: center;
  line-height: 58px;
  font-size: 20px;
}

.contact-forward-text-info {
  width: 78%;
  height: 100%;
}

.contact-forward-info-container {
  width: 74%;
  height: 90%;
}

.contact-forward-number {
  top: 5px;
  position: relative;
  margin-left: 10px;
  color: rgb(0, 119, 255);
  font-weight: bold;
  font-size: 20px;
  display: block;
}

.contact-forward-name {
  top: 7px;
  position: relative;
  margin-left: 10px;
  color: rgb(0, 119, 255);
  font-size: 10px;
  display: block;
}

.contact-forward-buttons-container {
  position: relative;
  width: 242px;
  /* bottom: 20px; */
  margin-top: -30px;
  height: 30px;
  display: -ms-flexbox;
  display: flex;
}

.contact-forward-button {
  width: 100%;
  height: 100%;
  border-top: 1px solid grey;
  text-align-last: center;
}

.contact-forward-button-text {
  color: rgb(0, 119, 255);
  font-weight: bold;
  font-size: 14px;
}
</style>
