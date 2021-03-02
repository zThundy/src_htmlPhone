<template>
  <div>

    <div class="phone_app">
      <PhoneTitle :title="channelName" :backgroundColor="'rgb(95, 94, 198)'" :textColor="'white'" @back="onQuit"/>
      
      <div style="padding-top: 20px;" class="slice"></div>
      
      <div style="background-color: #090f20;" class="phone_content">
        <div style="padding-top: 50px;" class="elementi" ref="elementsDiv">

          <div class="sms" v-bind:class="{ select: key === currentSelect}" v-for='(mess, key) in tchatMessages' v-bind:key="key">
            
            <span class='sms_message sms_me'>
              <span>{{mess.message}}</span>
            </span>

          </div>

        </div>

        <div style="width: 306px; bottom: 5px;" id='sms_write'>
          <input type="text" :placeholder="IntlString('APP_DARKTCHAT_PLACEHOLDER_ENTER_MESSAGE')">
          
          <div style="font-size: 10px;" class="sms_send">

            <svg height="24" viewBox="0 0 24 24" width="24">
              <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
              <path d="M0 0h24v24H0z" fill="none"/>
            </svg>

          </div>
        </div>

      </div>
    </div>

  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import PhoneTitle from './../PhoneTitle'

export default {
  components: { PhoneTitle },
  data () {
    return {
      message: '',
      channel: '',
      currentSelect: 0
    }
  },
  computed: {
    ...mapGetters(['tchatMessages', 'tchatCurrentChannel', 'IntlString']),
    channelName () {
      return '# ' + this.channel
    }
  },
  watch: {
    tchatMessages () {
      const c = this.$refs.elementsDiv
      c.scrollTop = c.scrollHeight
    }
  },
  methods: {
    setChannel (channel) {
      this.channel = channel
      this.tchatSetChannel({ channel })
    },
    ...mapActions(['tchatSetChannel', 'tchatSendMessage']),
    scrollIntoViewIfNeeded () {
      this.$nextTick(() => {
        const $select = this.$el.querySelector('.select')
        if ($select !== null) {
          $select.scrollIntoViewIfNeeded()
        }
      })
    },
    onUp () {
      // const c = this.$refs.elementsDiv
      // c.scrollTop = c.scrollTop - 120
      if (this.currentSelect === 0) return
      this.currentSelect = this.currentSelect - 1
      this.scrollIntoViewIfNeeded()
    },
    onDown () {
      // const c = this.$refs.elementsDiv
      // c.scrollTop = c.scrollTop + 120
      if (this.currentSelect === this.tchatMessages.length - 1) return
      this.currentSelect = this.currentSelect + 1
      this.scrollIntoViewIfNeeded()
    },
    async onEnter () {
      const rep = await this.$phoneAPI.getReponseText({ title: 'Digita il messaggio' })
      if (rep !== undefined && rep.text !== undefined) {
        const message = rep.text.trim()
        if (message.length !== 0) {
          this.tchatSendMessage({ channel: this.channel, message })
        }
      }
    },
    sendMessage () {
      const message = this.message.trim()
      if (message.length !== 0) {
        this.tchatSendMessage({ channel: this.channel, message })
        this.message = ''
      }
    },
    onBack () {
      if (document.activeElement.tagName !== 'BODY') return
      this.onQuit()
    },
    onQuit () {
      this.$router.push({ name: 'tchat.channel' })
    },
    formatTime (time) {
      const d = new Date(time)
      return d.toLocaleTimeString()
    }
  },
  created () {
    this.currentSelect = this.tchatMessages.length - 1
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
    this.setChannel(this.$route.params.channel)
  },
  mounted () {
    window.c = this.$refs.elementsDiv
    const c = this.$refs.elementsDiv
    c.scrollTop = c.scrollHeight
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.elementi {
  height: 100%;
  color: white;
  display: flex;
  flex-direction: column;
}

.elemento {
  top: 10px;
  color: #a6a28c;
  flex: 0 0 auto;
  width: 100%;
  display: flex;
}

.time {
  padding-right: 10px;
  font-size: 10px;
  margin-left: 15px;

}

.message {
  width: 100%;
  color: black;
  padding-left: 5px;
  padding-bottom: 3px;
}

.elementi::-webkit-scrollbar-track {
  box-shadow: inset 0 0 6px rgba(0,0,0,0.3);
  background-color: #a6a28c;
}

.elementi::-webkit-scrollbar {
  width: 3px;
  background-color: transparent;
}

.elementi::-webkit-scrollbar-thumb {
  background-color: #FFC629;
}

.slice {
  position: absolute;
  padding: 2rem 20%;
}

.slice:nth-child(2) {
  top: 24px;
  background: rgb(95, 94, 198);
  color: white;
  clip-path: polygon(0 58%, 400% 50%, 100% 50%, 0 100%);
  padding: 3rem 70% 25%;
}

/* Input message zone */

#sms_write {
  position: absolute;
  height: 56px;
  margin: 10px;
  width: 388px;
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

.sms{
  zoom: 1;
  bottom: 50px;
}

.sms.select .sms_message, .sms_message:hover{
  background-color:  #373B3C !important;
  color: #ffffff  !important;
}

.sms.select .sms_message, .sms_message:hover{
  background-color: #373B3C !important;
  color: #ffffff !important;
}

.sms_message {
  word-wrap: break-word;
  max-width: 80%;
  font-size: 24px;
}

.sms_me{
  float: right;
  background-color: #8f8f8f;
  border-radius: 17px;
  padding: 5px 10px;
  max-width: 90%;
  margin-right: 5%;
  margin-top: 10px;
}

</style>
