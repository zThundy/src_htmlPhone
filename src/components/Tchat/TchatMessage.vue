<template>
  <div class="phone_app">
    <PhoneTitle :title="channelName" :backgroundColor="'rgb(122, 122, 122)'" :textColor="'white'" @back="onQuit"/>
    
    <div class="messages-container">
      <div class="message-container" :class="{ select: key === currentSelect }" v-for='(mess, key) in tchatMessages' :key="key">
        <span class='sms_message'>
          <span>{{ formatEmoji(mess.message) }}</span>
        </span>
      </div>
    </div>

    <div style="background-color: rgb(26, 26, 26);" class="write-input-container">
      <div class='write-input'>
        <input type="text" :placeholder="LangString('APP_DARKTCHAT_PLACEHOLDER_ENTER_MESSAGE')">
        <i style="background-color: #373B3C;" class="fas fa-paper-plane"></i>
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
      this.currentSelect = this.tchatMessages.length - 1
      this.scrollIntoView()
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
      if (this.currentSelect === 0) return
      this.currentSelect = this.currentSelect - 1
      this.scrollIntoView()
    },
    onDown () {
      if (this.currentSelect === this.tchatMessages.length - 1) return
      this.currentSelect = this.currentSelect + 1
      this.scrollIntoView()
    },
    onEnter () {
      Modal.CreateTextModal({
        limit: 64,
        title: this.LangString('TYPE_MESSAGE'),
        color: 'rgb(194, 108, 7)'
      })
      .then(resp => {
        if (resp !== undefined && resp.text !== undefined) {
          const message = resp.text.trim()
          if (message.length !== 0) {
            this.tchatSendMessage({ channel: this.channel, message })
          }
        }
      })
      .catch(e => { })
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
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
    this.currentSelect = this.tchatMessages.length - 1
    this.scrollIntoView()
    this.setChannel(this.$route.params.channel)
  },
  // mounted () {},
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.messages-container {
  height: 100%;
  color: white;
  display: flex;
  flex-direction: column;
  position: relative;
  overflow: hidden;
  width: 100%;
  background-color: rgb(26, 26, 26);
}

.message-container {
  zoom: 1;
  bottom: 50px;
}

.message-container.select .sms_message {
  background-color:  #373B3C !important;
  color: #ffffff !important;
}

.sms_message {
  word-wrap: break-word;
  font-size: 24px;
  float: right;
  background-color: #8f8f8f;
  border-radius: 17px;
  padding: 5px 10px;
  max-width: 90%;
  margin-right: 5%;
  margin-top: 10px;
}
</style>
