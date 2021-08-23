<template>
  <div class="phone_app">
    <PhoneTitle :title="LangString('APP_DARKTCHAT_TITLE')" :backgroundColor="'rgb(122, 122, 122)'" :textColor="'white'" @back="onBack" />

    <div class="darkchat-channels" @contextmenu.prevent="addChannelOption">
      <div class="darkchat-channel" v-for='(elem, key) in tchatChannels' :key="elem.channel" :class="{ select: key === currentSelect}">
        <div class="glitch"># {{ formatEmoji(elem.channel) }}</div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import Modal from '@/components/Modal/index.js'
import PhoneTitle from './../PhoneTitle'

export default {
  components: { PhoneTitle },
  data: function () {
    return {
      currentSelect: 0,
      ignoreControls: false
    }
  },
  watch: {
    list: function () {
      this.currentSelect = 0
    }
  },
  computed: {
    ...mapGetters(['LangString', 'tchatChannels'])
  },
  methods: {
    ...mapActions(['tchatAddChannel', 'tchatRemoveChannel']),
    formatEmoji (message) {
      return this.$phoneAPI.convertEmoji(message)
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
      if (this.ignoreControls === true) return
      this.currentSelect = this.currentSelect === 0 ? 0 : this.currentSelect - 1
      this.scrollIntoView()
    },
    onDown () {
      if (this.ignoreControls === true) return
      this.currentSelect = this.currentSelect === this.tchatChannels.length - 1 ? this.currentSelect : this.currentSelect + 1
      this.scrollIntoView()
    },
    async onRight () {
      if (this.ignoreControls === true) return
      this.ignoreControls = true
      let scelte = [
        {id: 1, title: this.LangString('APP_DARKTCHAT_NEW_CHANNEL'), icons: 'fa-plus', color: 'green'},
        {id: 2, title: this.LangString('APP_DARKTCHAT_DELETE_CHANNEL'), icons: 'fa-minus', color: 'orange'},
        {id: 3, title: this.LangString('APP_DARKTCHAT_CANCEL'), icons: 'fa-undo', color: 'red'}
      ]
      if (this.tchatChannels.length === 0) {
        scelte.splice(1, 1)
      }
      const rep = await Modal.CreateModal({ scelte })
      this.ignoreControls = false
      switch (rep.id) {
        case 1:
          this.addChannelOption()
          break
        case 2:
          this.removeChannelOption()
          break
        case 3 :
      }
    },
    async onEnter () {
      if (this.ignoreControls === true) return
      if (this.tchatChannels.length === 0) {
        this.ignoreControls = true
        let scelte = [
          {id: 1, title: this.LangString('APP_DARKTCHAT_NEW_CHANNEL'), icons: 'fa-plus', color: 'green'},
          {id: 3, title: this.LangString('APP_DARKTCHAT_CANCEL'), icons: 'fa-undo', color: 'red'}
        ]
        const rep = await Modal.CreateModal({ scelte })
        this.ignoreControls = false
        if (rep.id === 1) {
          this.addChannelOption()
        }
      } else {
        const channel = this.tchatChannels[this.currentSelect].channel
        this.showChannel(channel)
      }
    },
    showChannel (channel) {
      this.$router.push({ name: 'tchat.channel.show', params: { channel } })
    },
    onBack () {
      if (this.ignoreControls === true) return
      this.$router.push({ name: 'menu' })
    },
    async addChannelOption () {
      try {
        this.ignoreControls = true
        const rep = await Modal.CreateTextModal({ limit: 20, title: this.LangString('APP_DARKTCHAT_NEW_CHANNEL') })
        let channel = (rep || {}).text || ''
        channel = channel.toLowerCase().replace(/[^a-z]/g, '')
        for (var i in this.tchatChannels) {
          if (this.tchatChannels[i].channel === channel) {
            this.$phoneAPI.sendErrorMessage(this.LangString('APP_DARKCHAT_ERROR_NOTIFICATION'))
            this.ignoreControls = false
            return
          }
        }
        // questo controllo sotto vede se
        // il canale ha un nome abbastanza lungo
        if (channel.length > 0 && channel.length < 30) {
          this.currentSelect = 0
          this.tchatAddChannel({ channel })
          this.ignoreControls = false
        }
      } catch (e) { } finally { this.ignoreControls = false }
    },
    async removeChannelOption () {
      const channel = this.tchatChannels[this.currentSelect].channel
      this.currentSelect = 0
      this.tchatRemoveChannel({ channel })
    }
  },
  created () {
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style type="scss">
.darkchat-channels {
  height: 100%;
  width: 100%;
  overflow-y: hidden;
  background-color: rgb(26, 26, 26);
}

.darkchat-channel {
  height: 42px;
  line-height: 42px;
  display: flex;
  align-items: center;
  position: relative;
  padding-left: 10px;
}

.darkchat-channel.select {
  background-color: rgba(255, 255, 255, 0.08);
}

.glitch {
  left: 10px;
  align-items: center;
  justify-content: center;
  margin: 0;
  background: #13131300;
  color: #fff;
  font-size: 25px;
  font-family: 'Fira Mono', monospace;
  animation: glitch 1s linear infinite;
}

@keyframes glitch {
  2%, 64% { transform: translate(2px, 0) skew(0deg); }
  4%, 60% { transform: translate(-2px, 0) skew(0deg); }
  62% { transform: translate(0, 0) skew(5deg); }
}

.glitch:before, .glitch:after {
  content: attr(title);
  position: absolute;
  left: 0;
}

.glitch:before {
  animation: glitchTop 1s linear infinite;
  clip-path: polygon(0 0, 100% 0, 100% 33%, 0 33%);
  -webkit-clip-path: polygon(0 0, 100% 0, 100% 33%, 0 33%);
}

@keyframes glitchTop {
  2%, 64% { transform: translate(2px, -2px); }
  4%, 60% { transform: translate(-2px, 2px); }
  62% { transform: translate(13px, -1px) skew(-13deg); }
}

.glitch:after {
  animation: glitchBotom 1.5s linear infinite;
  clip-path: polygon(0 67%, 100% 67%, 100% 100%, 0 100%);
  -webkit-clip-path: polygon(0 67%, 100% 67%, 100% 100%, 0 100%);
}

@keyframes glitchBotom {
  2%, 64%{ transform: translate(-2px, 0); }
  4%, 60%{ transform: translate(-2px, 0); }
  62% { transform: translate(-22px, 5px) skew(21deg); }
}
</style>
