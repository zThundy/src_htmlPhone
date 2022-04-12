<template>
  <div style="backgroundColor: white" class="phone_app messages">
    <PhoneTitle :backgroundColor="'rgb(194, 108, 7)'" :title="formatEmoji(displayContact)" style="color: black" /> <!--:title="displayContact" :backgroundColor="color" -->
    
    <div class="phone_fullscreen_img" v-if="imgZoom">
      <img v-if="imgZoom.type === 'photo'" :src="imgZoom.link" />
      <video v-else-if="imgZoom.type === 'video'" width="330" height="710" id="video-playback-element" :src="imgZoom.link" autoplay />
    </div>
    
    <div id='sms_list'>
      <div style="position: absolute;" class="groupImage" data-type="button">
        <img v-if="isSMSImage(getContactIcon())" :src="getContactIcon()"/>
      </div>

      <div class="sms" v-bind:class="{ select: key === selectMessage }" v-for='(mess, key) in messagesListApp' :key="mess.id">
        <div class="sms_message_time">
          <h6 :class="{ sms_me : mess.owner === 1 }" class="name_other_sms_other"><timeago class="sms_time" :since='mess.time' :auto-update="20"></timeago></h6>
        </div>

        <span class='sms_message sms_me' :class="{ sms_other : mess.owner === 0 }">
          <img v-if="isSMSImage(mess.message)" class="sms-img" :src="mess.message"/>

          <div v-else-if="isSMSContact(mess.message)" class="contact-forward-container">
            <div class="contact-forward-background">
              <div class="contact-forward-pic" :style="stylePuce(mess)">{{ getSMSContactInfo(mess.message).letter }}</div>
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

          <div v-else-if="isSMSVideo(mess.message)" class="video-message-container">
            <i class="fas fa-play"></i>
          </div>
          
          <span v-else class="sms_message">{{ formatEmoji(mess.message) }}</span>
        </span>

      </div>
    </div>

    <div class="write-input-container">
      <div class='write-input'>
        <input type="text" :placeholder="LangString('APP_DARKTCHAT_PLACEHOLDER_ENTER_MESSAGE')">
        <i class="fas fa-paper-plane"></i>
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
  name: 'messages-screen',
  components: { PhoneTitle },
  data () {
    return {
      ignoreControls: false,
      selectMessage: -1,
      display: '',
      phoneNumber: '',
      imgZoom: null,
      videoElement: null,
      message: '',
      letter: ''
    }
  },
  computed: {
    ...mapGetters(['LangString', 'messages', 'contacts', 'config']),
    messagesListApp () {
      return this.messages.filter(e => e.transmitter === this.phoneNumber).sort((a, b) => a.time - b.time)
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
  methods: {
    ...mapActions(['setMessageRead']),
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
    onUp () {
      if (this.ignoreControls) return
      if (this.selectMessage === -1) {
        this.selectMessage = this.messagesListApp.length - 1
      } else {
        this.selectMessage = this.selectMessage === 0 ? 0 : this.selectMessage - 1
      }
      this.scrollIntoView()
    },
    onDown () {
      if (this.ignoreControls) return
      if (this.selectMessage === -1) {
        this.selectMessage = this.messagesListApp.length - 1
      } else {
        this.selectMessage = this.selectMessage === this.messagesListApp.length - 1 ? this.selectMessage : this.selectMessage + 1
      }
      this.scrollIntoView()
    },
    onEnter () {
      if (this.ignoreControls) return
      if (this.imgZoom && this.imgZoom.type) {
        if (this.imgZoom.type === 'video') {
          this.restartVideo()
          return
        }
      }
      if (this.selectMessage !== -1) {
        this.onActionMessage(this.messagesListApp[this.selectMessage])
      } else {
        Modal.CreateTextModal({
          title: this.LangString('TYPE_MESSAGE'),
          color: 'rgb(194, 108, 7)'
        })
        .then(resp => {
          let message = resp.text.trim()
          if (message && message !== '') this.$phoneAPI.post('sendMessage', { phoneNumber: this.phoneNumber, message: message })
          this.ignoreControls = false
        })
        .catch(e => { this.ignoreControls = false })
      }
    },
    send () {
      const message = this.message.trim()
      if (message === '') return
      this.message = ''
      this.$phoneAPI.post('sendMessage', { phoneNumber: this.phoneNumber, message: message })
    },
    isSMSImage (mess) {
      return this.$phoneAPI.isLink(mess)
    },
    isSMSContact (mess) {
      return mess.indexOf('[CONTACT]') === 0
    },
    isSMSVideo (mess) {
      return mess.indexOf('[VIDEO]') === 0
    },
    getSMSContactInfo (mess) {
      var obj = mess.split('%')
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
      data.icon = this.getSMSContactInfo(data.message).icon
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
            return { backgroundColor: this.color }
          }
        }
      }
    },
    restartVideo () {
      this.videoElement = document.getElementById('video-playback-element')
      this.videoElement.currentTime = 0
      this.videoElement.play()
    },
    async onActionMessage (elem) {
      try {
        let isGPS = /(-?\d+(\.\d+)?), (-?\d+(\.\d+)?)/.test(elem.message)
        let hasNumber = /#([0-9]+)/.test(elem.message)
        let scelte = [
          { id: 'inoltra', title: this.LangString('APP_MESSAGE_INOLTRA_IMG'), icons: 'fa-paper-plane' },
          { id: 'delete', title: this.LangString('APP_MESSAGE_DELETE'), icons: 'fa-trash' },
          { id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' }
        ]
        if (isGPS) scelte = [{ id: 'gps', title: this.LangString('APP_MESSAGE_SET_GPS'), icons: 'fa-location-arrow' }, ...scelte]
        if (this.isSMSContact(elem.message)) scelte = [{ id: 'add_contact', title: this.LangString('APP_MESSAGE_ADD_CONTACT'), icons: 'fa-plus' }, ...scelte]
        if (hasNumber) {
          const num = elem.message.match(/#([0-9-]*)/)[1]
          scelte = [{ id: 'num', title: `${this.LangString('APP_MESSAGE_MESS_NUMBER')} ${num}`, number: num, icons: 'fa-phone' }, ...scelte]
        }
        if (this.isSMSImage(elem.message)) scelte = [{ id: 'zoom', title: this.LangString('APP_MESSAGE_ZOOM_IMG'), icons: 'fa-search' }, ...scelte]
        if (this.isSMSVideo(elem.message)) scelte = [{ id: 'video', title: this.LangString('APP_MESSAGE_PLAY_VIDEO'), icons: 'fa-play' }, ...scelte]
        this.ignoreControls = true
        Modal.CreateModal({ scelte })
        .then(data => {
          this.ignoreControls = false
          switch(data.id) {
            case 'delete':
              this.$phoneAPI.post('deleteMessage', { id: elem.id })
              break
            case 'gps':
              let val = elem.message.match(/(-?\d+(\.\d+)?), (-?\d+(\.\d+)?)/)
              this.$phoneAPI.setGPS(val[1], val[3])
              break
            case 'num':
              this.$nextTick(() => { this.onSelectPhoneNumber(data.number) })
              break
            case 'zoom':
              this.imgZoom = { type: 'photo', link: elem.message }
              this.CHANGE_BRIGHTNESS_STATE(false)
              break
            case 'inoltra':
              this.$router.push({ name: 'messages.chooseinoltra', params: { message: elem.message } })
              break
            case 'add_contact':
              var c = this.getSMSContactInfo(elem.message)
              this.$router.push({ name: 'contacts.view', params: { id: -1, isForwarded: true, number: c.number, display: c.name, email: c.email, icon: c.icon } })
              break
            case 'message_contact':
              var c = this.getSMSContactInfo(elem.message)
              this.$router.push({ name: 'messages.view', params: { number: c.number, display: c.name } })
              break
            case 'video':
              let id = elem.message.split('%')
              if (id[2]) {
                this.$phoneAPI.videoRequest.getVideoLinkFromServer(id[2]).then(link => {
                  if (link) {
                    this.imgZoom = { type: 'video', link: link }
                    this.CHANGE_BRIGHTNESS_STATE(false)
                    this.restartVideo()
                  } else {
                    this.$phoneAPI.ongenericNotification({
                      message: 'VIDEO_NOT_FOUND',
                      title: 'VIDEO_ERROR_TITLE',
                      icon: 'camera',
                      color: 'rgb(205, 116, 76)',
                      appName: 'Messaggi'
                    })
                  }
                })
              }
              break
          }
        })
        .catch(e => { this.ignoreControls = false })
      } catch (e) {}
    },
    onSelectPhoneNumber (number) {
      this.ignoreControls = true
      Modal.CreateModal({ scelte: [
        { id: 'sms', title: this.LangString('APP_MESSAGE_MESS_SMS'), icons: 'fa-comment' },
        { id: 'call', title: this.LangString('APP_MESSAGE_MESS_CALL'), icons: 'fa-phone' },
        { id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' }
      ] })
      .then(data => {
        switch(data.id) {
          case 'sms':
            this.phoneNumber = number
            this.display = undefined
            break
          case 'call':
            this.$phoneAPI.startCall({ numero: number })
            break
        }
        this.ignoreControls = false
        this.selectMessage = -1
      })
      .catch(e => { this.ignoreControls = false })
    },
    onBackspace () {
      if (this.imgZoom) {
        this.imgZoom = undefined
        this.CHANGE_BRIGHTNESS_STATE(true)
        return
      }
      if (this.ignoreControls) return
      if (this.selectMessage !== -1) {
        this.selectMessage = -1
      } else {
        this.$router.go(-1)
      }
    },
    onRight: function () {
      if (this.ignoreControls) return
      if (this.selectMessage === -1) this.showOptions()
    },
    showOptions () {
      this.ignoreControls = true
      let scelte = [
        { id: 1, title: this.LangString('APP_MESSAGE_SEND_GPS'), icons: 'fa-location-arrow' },
        { id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' }
      ]
      if (this.config.picturesConfig.enabled) scelte = [{ id: 2, title: this.LangString('APP_MESSAGE_SEND_PHOTO'), icons: 'fa-image' }, ...scelte]
      Modal.CreateModal({ scelte: scelte })
      .then(async data => {
        this.ignoreControls = false
        switch(data.id) {
          case 1:
            this.$phoneAPI.post('sendMessage', { phoneNumber: this.phoneNumber, message: '%pos%' })
            break
          case 2:
            this.$phoneAPI.takePhoto()
            .then(pic => {
              this.$phoneAPI.post('sendMessage', { phoneNumber: this.phoneNumber, message: pic })
              this.ignoreControls = false
            })
            .catch(e => { this.ignoreControls = false })
            break
        }
      })
      .catch(e => { this.ignoreControls = false })
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

/* VIDEO MESSAGE SECTION */

.video-message-container {
  margin-top: 5px;
  width: 200px;
  height: 100px;
  background-color: black;
  border-radius: 10px;
  text-align: center;
}

.video-message-container i {
  color: white;
  font-size: 20px;
  margin-top: 20%;
}

.write-input-container {
  width: 330px;
  height: 55px;
  bottom: 5px;
  position: relative;
  background-color: white;
}

.write-input {
  position: relative;
  height: 40px;
  width: 90%;
  background-color: #e9e9eb;
  border-radius: 56px;
  margin-left: auto;
  margin-right: auto;
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.6);
}

.write-input input {
  height: 100%;
  border: none;
  outline: none;
  font-size: 15px;
  margin-left: 14px;
  padding: 12px 5px;
  background-color: rgba(236, 236, 241, 0)
}

.write-input i {
  height: 50px;
  width: 50px;
  font-size: 15px;
  bottom: 5px;
  color: #e2e2e2;
  float: right;
  position: relative;
  padding-top: 16px;
  border-radius: 50px;
  text-align-last: center;
  background-color: rgb(194, 108, 7);
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.6);
  transition: all .5s ease;
}
</style>
