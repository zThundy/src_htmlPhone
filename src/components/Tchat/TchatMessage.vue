<template>
  <div class="phone_app">
    <PhoneTitle :title="channelName" :backgroundColor="'rgb(122, 122, 122)'" :textColor="'white'" @back="onQuit"/>
    
    <div style="padding-top: 20px;" class="slice"></div>
    
    <div style="background-color: rgb(26, 26, 26);" class="phone_content">
      <div style="padding-top: 50px;" class="elementi" ref="elementsDiv">
        <div class="sms" :class="{ select: key === currentSelect }" v-for='(mess, key) in tchatMessages' :key="key">
          <span class='sms_message sms_me'>
            <span>{{ formatEmoji(mess.message) }}</span>
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
    ...mapGetters(['tchatMessages', 'tchatCurrentChannel', 'LangString']),
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
    formatEmoji (message) {
      return this.$phoneAPI.convertEmoji(message)
    },
    ...mapActions(['tchatSetChannel', 'tchatSendMessage']),
    scrollIntoView () {
      this.$nextTick(() => {
        const elem = this.$el.querySelector('.select')
        if (elem !== null) {
          elem.scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' })
        }
      })
    },
    onUp () {
      // const c = this.$refs.elementsDiv
      // c.scrollTop = c.scrollTop - 120
      if (this.currentSelect === 0) return
      this.currentSelect = this.currentSelect - 1
      this.scrollIntoView()
    },
    onDown () {
      // const c = this.$refs.elementsDiv
      // c.scrollTop = c.scrollTop + 120
      if (this.currentSelect === this.tchatMessages.length - 1) return
      this.currentSelect = this.currentSelect + 1
      this.scrollIntoView()
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
  margin-top: 50px;
  height: 85%;
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
  background: rgb(122, 122, 122);
  color: white;
  clip-path: polygon(0 58%, 400% 50%, 100% 50%, 0 100%);
  padding: 3rem 70% 25%;
}

.sms {
  zoom: 1;
  bottom: 50px;
}

.sms.select .sms_message {
  background-color:  #373B3C !important;
  color: #ffffff  !important;
}

.sms.select .sms_message {
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

.write-input-container {
  width: 330px;
  height: 50px;
  position: relative;
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
  background-color: #373B3C;
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.6);
  transition: all .5s ease;
}

</style>
