<template>
  <div style="height: 100%;">
    
    <div class="phone_fullscreen_img" v-if="imgZoom !== undefined">
      <img :src="imgZoom" />
    </div>

    <div class="dark-wrapper" ref="elementsDiv">
      <div class="darkweb" v-for='(val, key) in darkwebMessages' v-bind:key="key" v-bind:class="{ select: key === currentSelected }">
        <div class="dark-content">
          <div class="dark-head">
            <div class="dark-head-author">{{ LangString("APP_DARKWEB_USER_TITLE") }}</div>
            <i v-if="val.mine == 1" class="dark-user-icon fa fa-user"></i>
          </div>

          <div class="dark-message">
            <template v-if="!isImage(val.message)">{{ formatEmoji(val.message) }}</template>
            <img v-else :src="val.message" class="dark-message-img">
          </div>

          <div class="dark-like-content">
            <div class="item">
              <i class="fa fa-comment" aria-hidden="true"/>
              <!-- <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"><path fill="none" d="M0 0h24v24H0V0z"/><path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm0 14H6l-2 2V4h16v12z"/></svg> -->
            </div>
            
            <div class="item">
              <i class="fa fa-retweet" aria-hidden="true"/>
              <!-- <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"><path d="M0 0h24v24H0z" fill="none"/><path d="M7 7h10v3l4-4-4-4v3H5v6h2V7zm10 10H7v-3l-4 4 4 4v-3h12v-6h-2v4z"/></svg> -->
            </div>
            
            <div class="item">
              <i class="fa fa-flag" aria-hidden="true"/>
              <!-- <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"><path fill="none" d="M0 0h24v24H0V0z"/><path d="M18 16.08c-.76 0-1.44.3-1.96.77L8.91 12.7c.05-.23.09-.46.09-.7s-.04-.47-.09-.7l7.05-4.11c.54.5 1.25.81 2.04.81 1.66 0 3-1.34 3-3s-1.34-3-3-3-3 1.34-3 3c0 .24.04.47.09.7L8.04 9.81C7.5 9.31 6.79 9 6 9c-1.66 0-3 1.34-3 3s1.34 3 3 3c.79 0 1.5-.31 2.04-.81l7.12 4.16c-.05.21-.08.43-.08.65 0 1.61 1.31 2.92 2.92 2.92s2.92-1.31 2.92-2.92-1.31-2.92-2.92-2.92z"/></svg> -->
            </div>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
import { mapGetters, mapActions, mapMutations } from 'vuex'
import Modal from '@/components/Modal/index.js'

export default {
  components: {},
  data () {
    return {
      currentSelected: -1,
      ignoreControls: false,
      imgZoom: undefined
    }
  },
  computed: {
    ...mapGetters(['darkwebMessages', 'LangString'])
  },
  watch: {
  },
  methods: {
    ...mapActions(['darkwebPostMessage']),
    ...mapMutations(['CHANGE_BRIGHTNESS_STATE']),
    formatEmoji (message) {
      return this.$phoneAPI.convertEmoji(message)
    },
    async showOption () {
      this.ignoreControls = true
      const message = this.darkwebMessages[this.currentSelected]
      let optionsChoix = [{
        id: 1,
        title: this.LangString('APP_DARKWEB_REPLY'),
        icons: 'fa-retweet'
      }, {
        id: -1,
        title: this.LangString('CANCEL'),
        icons: 'fa-undo',
        color: 'red'
      }]
      if (this.isImage(message.message)) {
        optionsChoix = [{
          id: 2,
          title: this.LangString('APP_MESSAGE_ZOOM_IMG'),
          icons: 'fa-search'
        }, ...optionsChoix]
      }
      const scelte = await Modal.CreateModal({ scelte: optionsChoix })
      this.ignoreControls = false
      switch (scelte.id) {
        case 1:
          this.reply(message)
          break
        case 2:
          this.imgZoom = message.message
          this.CHANGE_BRIGHTNESS_STATE(false)
          break
      }
    },
    async reply (message) {
      // const authorName = message.author
      const authorName = this.currentSelected
      try {
        this.ignoreControls = true
        const rep = await Modal.CreateTextModal({ title: 'Rispondi', text: `@${authorName} ` })
        if (rep !== undefined && rep.text !== undefined) {
          const message = rep.text.trim()
          if (message.length !== 0) {
            this.darkwebPostMessage({ message, mine: 1 })
          }
        }
      } catch (e) {
      } finally {
        this.ignoreControls = false
      }
    },
    resetScroll () {
      this.$nextTick(() => {
        let elem = document.querySelector('#darkweb')
        elem.scrollTop = elem.scrollHeight
        this.currentSelected = -1
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
      if (this.ignoreControls === true) return
      this.currentSelected = this.currentSelected === 0 || this.currentSelected === -1 ? 0 : this.currentSelected - 1
      this.scrollIntoView()
    },
    onDown () {
      if (this.ignoreControls === true) return
      this.currentSelected = this.currentSelected === this.darkwebMessages.length - 1 ? this.currentSelected : this.currentSelected + 1
      this.scrollIntoView()
    },
    async onEnter () {
      if (this.ignoreControls === true) return
      if (this.currentSelected !== -1) {
        this.showOption()
      }
    },
    onBack () {
      if (this.imgZoom !== undefined) {
        this.imgZoom = undefined
        this.CHANGE_BRIGHTNESS_STATE(true)
        return
      }
      if (this.ignoreControls === true) return
      if (this.currentSelected !== -1) {
        this.currentSelected = -1
      } else {
        this.$router.push({ name: 'menu' })
      }
    },
    formatTime (time) {
      const d = new Date(time)
      return d.toLocaleTimeString()
    },
    isImage (mess) {
      return this.$phoneAPI.isLink(mess)
    }
  },
  created () {
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  mounted () {
    this.$phoneAPI.fetchDarkmessages()
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
.darkweb {
  background-color: white;
  flex: 0 0 auto;
  width: 100%;
  display: flex;
  flex-direction: row;
  border-bottom: #CCC 1px solid;
  padding-top: 6px;
}

.darkweb.select {
  background-color: #dfdfdf;
}

.dark-user-icon {
  position: absolute;
  left: 12px;
  top: 5px;
}

.dark-wrapper {
  height: 100%;
  background-color: #eeeeee;
  color: black;
  display: flex;
  flex-direction: column;
  overflow-y: auto;
}

.message-img {
  width: 322px;
  display: flex;
  justify-content: center;
}

.message-img img {
  border-radius: 5px;
}

.dark-content {
  position: relative;
  justify-content: center;
  text-align: center;
  width: 100%;
}

.dark-head {
  padding-bottom: 6px;
  font-size: 14px;
  display: flex;
  flex-direction: row;
  font-weight: 700;
}

.dark-head-author {
  width: 100%;
  font-weight: bold;
}

.dark-message {
  font-size: 14px;
  color: 000;
  min-height: 36px;
  width: 100%;
  word-break: break-word;
}

.dark-message img {
  position: relative;
  margin: auto;
}

.dark-message-img {
  border-radius: 15px;
  width: 90%;
}

.dark-like-content {
  margin-bottom: 3px;

  display: flex;
  position: relative;
  justify-content: center;
  width: 100%;
  height: 24px;
  font-size: 12px;
  line-height: 24px;
  font-weight: 700;
}

.item i {
  font-size: 12px;
}

.dark-like-content div {
  width: 80px;
}

.elements::-webkit-scrollbar-track {
  box-shadow: inset 0 0 6px rgba(0,0,0,0.3);
  background-color: #a6a28c;
}

.elements::-webkit-scrollbar {
  width: 3px;
  background-color: transparent;
}
</style>
