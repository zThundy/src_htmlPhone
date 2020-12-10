<template>
  <div class="phone_app">
    <PhoneTitle :title="IntlString('APP_DARKTCHAT_TITLE')" backgroundColor="#090f20" :textColor="'white'" @back="onBack" />
    
    <div style="padding-top: 30px;" class="slice"></div>

    <div class="elementi" style="padding-top: 47px; padding-left:10px;" @contextmenu.prevent="addChannelOption">
      <div class="elemento" style="background-color: rgb(26, 26, 26);" v-for='(elem, key) in tchatChannels' 
        v-bind:key="elem.channel"
        v-bind:class="{ select: key === currentSelect}"
      >

        <!-- <span class="diese">#</span>{{elem.channel}} -->
        <div class="elem-title">
          <div class="glitch"># {{elem.channel}}</div>
        </div>
      </div>

    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import Modal from '@/components/Modal/index.js'
import PhoneTitle from './../PhoneTitle'
import PhoneAPI from './../../PhoneAPI'

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
    ...mapGetters(['IntlString', 'tchatChannels'])
  },
  methods: {
    ...mapActions(['tchatAddChannel', 'tchatRemoveChannel']),
    scrollIntoViewIfNeeded () {
      this.$nextTick(() => {
        const $select = this.$el.querySelector('.select')
        if ($select !== null) {
          $select.scrollIntoViewIfNeeded()
        }
      })
    },
    onUp () {
      if (this.ignoreControls === true) return
      this.currentSelect = this.currentSelect === 0 ? 0 : this.currentSelect - 1
      this.scrollIntoViewIfNeeded()
    },
    onDown () {
      if (this.ignoreControls === true) return
      this.currentSelect = this.currentSelect === this.tchatChannels.length - 1 ? this.currentSelect : this.currentSelect + 1
      this.scrollIntoViewIfNeeded()
    },
    async onRight () {
      if (this.ignoreControls === true) return
      this.ignoreControls = true
      let choix = [
        {id: 1, title: this.IntlString('APP_DARKTCHAT_NEW_CHANNEL'), icons: 'fa-plus', color: 'green'},
        {id: 2, title: this.IntlString('APP_DARKTCHAT_DELETE_CHANNEL'), icons: 'fa-minus', color: 'orange'},
        {id: 3, title: this.IntlString('APP_DARKTCHAT_CANCEL'), icons: 'fa-undo', color: 'red'}
      ]
      if (this.tchatChannels.length === 0) {
        choix.splice(1, 1)
      }
      const rep = await Modal.CreateModal({ choix })
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
        let choix = [
          {id: 1, title: this.IntlString('APP_DARKTCHAT_NEW_CHANNEL'), icons: 'fa-plus', color: 'green'},
          {id: 3, title: this.IntlString('APP_DARKTCHAT_CANCEL'), icons: 'fa-undo', color: 'red'}
        ]
        const rep = await Modal.CreateModal({ choix })
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
      this.$router.push({ name: 'home' })
    },
    async addChannelOption () {
      try {
        this.ignoreControls = true
        const rep = await Modal.CreateTextModal({ limit: 20, title: this.IntlString('APP_DARKTCHAT_NEW_CHANNEL') })
        let channel = (rep || {}).text || ''
        channel = channel.toLowerCase().replace(/[^a-z]/g, '')
        for (var i in this.tchatChannels) {
          if (this.tchatChannels[i].channel === channel) {
            PhoneAPI.sendErrorMessage(this.IntlString('APP_DARKCHAT_ERROR_NOTIFICATION'))
            this.ignoreControls = false
            return
          }
        }
        // questo controllo sotto vede se
        // il canale ha un nome abbastanza lungo
        if (channel.length > 0) {
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
.list{
  height: 100%;
}

.title{
  padding-top: 22px;
  padding-left: 16px;
  height: 54px;
  line-height: 34px;
  font-weight: 700;
  color: white;
}

.elementi{
  height: calc(100% - 54px);
  overflow-y: auto;
  background-color: rgb(26, 26, 26);
  color: #a6a28c
}
.elemento{
  height: 42px;
  line-height: 42px;
  display: flex;
  align-items: center;
  position: relative;
}

.elem-title{
  margin-left: 6px;
  font-size: 20px;
  text-transform: capitalize;
  transition: .15s;
  font-weight: 400;
}

.elem-title .diese {
  color: #0079d3;
  font-size: 22px;
  font-weight: 700;
  line-height: 40px;
}

.elemento.select, .elemento:hover{
   background-color: rgba(255, 255, 255, 0.082);
   color: #0079d3;
   
}
.elemento.select .elem-title, .elemento:hover .elem-title {
  margin-left: 15px;
}
.elemento.select .elem-title .diese, .elemento:hover .elem-title .diese {
  color:#0079d3;
}

.elementi::-webkit-scrollbar-track {
  box-shadow: inset 0 0 6px rgba(0,0,0,0.3);
  background-color: #F5F5F5;
}
.elementi::-webkit-scrollbar {
  width: 3px;
  background-color: transparent;
}
.elementi::-webkit-scrollbar-thumb {
  background-color: #0079d3;
}

.slice {
  position: absolute;
  padding: 2rem 20%;
}

.slice:nth-child(2) {
  top: 27px;
  background: #090f20;
  color: white;
  clip-path: polygon(0 58%, 400% 50%, 100% 50%, 0 100%);
  padding: 3rem 70% 25%;
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

@keyframes glitch{
  2%,64%{
    transform: translate(2px,0) skew(0deg);
  }
  4%,60%{
    transform: translate(-2px,0) skew(0deg);
  }
  62%{
    transform: translate(0,0) skew(5deg); 
  }
}

.glitch:before,
.glitch:after{
  content: attr(title);
  position: absolute;
  left: 0;
}

.glitch:before{
  animation: glitchTop 1s linear infinite;
  clip-path: polygon(0 0, 100% 0, 100% 33%, 0 33%);
  -webkit-clip-path: polygon(0 0, 100% 0, 100% 33%, 0 33%);
}

@keyframes glitchTop{
  2%,64%{
    transform: translate(2px,-2px);
  }
  4%,60%{
    transform: translate(-2px,2px);
  }
  62%{
    transform: translate(13px,-1px) skew(-13deg); 
  }
}

.glitch:after{
  animation: glitchBotom 1.5s linear infinite;
  clip-path: polygon(0 67%, 100% 67%, 100% 100%, 0 100%);
  -webkit-clip-path: polygon(0 67%, 100% 67%, 100% 100%, 0 100%);
}

@keyframes glitchBotom{
  2%,64%{
    transform: translate(-2px,0);
  }
  4%,60%{
    transform: translate(-2px,0);
  }
  62%{
    transform: translate(-22px,5px) skew(21deg); 
  }
}
</style>
