<template>
  <div style="width: 326px; height: 743px;" class="phone_content">
    <div class="img-fullscreen" v-if="imgZoom !== undefined">
      <img :src="imgZoom" />
    </div>

    <div class="dark-wrapper" ref="elementsDiv">

      <div class="darkweb" v-for='(val, key) in darkwebMessages' v-bind:key="key" v-bind:class="{ select: key === selectMessage }">

        <div class="dark-content">

          <div class="dark-head">
            <div class="dark-head-author">{{ IntlString("APP_DARKWEB_USER_TITLE") }}</div>
            <i v-if="val.mine == 1" class="dark-user-icon fa fa-user"></i>
          </div>

          <div class="dark-message">
            <template v-if="!isImage(val.message)">{{ val.message }}</template>
            <img v-else :src="val.message" class="dark-message-img">
          </div>

          <div class="dark-like-content">

            <div class="item">
              <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"><path fill="none" d="M0 0h24v24H0V0z"/><path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm0 14H6l-2 2V4h16v12z"/></svg>
            </div>
            
            <div class="item">
              <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"><path d="M0 0h24v24H0z" fill="none"/><path d="M7 7h10v3l4-4-4-4v3H5v6h2V7zm10 10H7v-3l-4 4 4 4v-3h12v-6h-2v4z"/></svg>
            </div>
            
            <div class="item">
              <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"><path fill="none" d="M0 0h24v24H0V0z"/><path d="M18 16.08c-.76 0-1.44.3-1.96.77L8.91 12.7c.05-.23.09-.46.09-.7s-.04-.47-.09-.7l7.05-4.11c.54.5 1.25.81 2.04.81 1.66 0 3-1.34 3-3s-1.34-3-3-3-3 1.34-3 3c0 .24.04.47.09.7L8.04 9.81C7.5 9.31 6.79 9 6 9c-1.66 0-3 1.34-3 3s1.34 3 3 3c.79 0 1.5-.31 2.04-.81l7.12 4.16c-.05.21-.08.43-.08.65 0 1.61 1.31 2.92 2.92 2.92s2.92-1.31 2.92-2.92-1.31-2.92-2.92-2.92z"/></svg>
            </div>

          </div>

        </div>

      </div>
      
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import Modal from '@/components/Modal/index.js'

export default {
  components: {},
  data () {
    return {
      selectMessage: -1,
      ignoreControls: false,
      imgZoom: undefined
    }
  },
  computed: {
    ...mapGetters(['darkwebMessages', 'IntlString'])
  },
  watch: {
  },
  methods: {
    ...mapActions(['darkwebPostMessage']),
    async showOption () {
      this.ignoreControls = true
      const tweet = this.darkwebMessages[this.selectMessage]
      let optionsChoix = [{
        id: 1,
        title: this.IntlString('APP_TWITTER_REPLY'),
        icons: 'fa-retweet'
      }, {
        id: -1,
        title: this.IntlString('CANCEL'),
        icons: 'fa-undo',
        color: 'red'
      }]
      if (this.isImage(tweet.message)) {
        optionsChoix = [{
          id: 2,
          title: this.IntlString('APP_MESSAGE_ZOOM_IMG'),
          icons: 'fa-search'
        }, ...optionsChoix]
      }
      const choix = await Modal.CreateModal({ choix: optionsChoix })
      this.ignoreControls = false
      switch (choix.id) {
        case 1:
          this.reply(tweet)
          break
        case 2:
          this.imgZoom = tweet.message
          break
      }
    },
    isImage (mess) {
      return /^https?:\/\/.*\.(png|jpg|jpeg|gif)/.test(mess)
    },
    async reply (tweet) {
      const authorName = tweet.author
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
        this.selectMessage = -1
      })
    },
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
      if (this.selectMessage === -1) {
        this.selectMessage = 0
      } else {
        this.selectMessage = this.selectMessage === 0 ? 0 : this.selectMessage - 1
      }
      this.scrollIntoViewIfNeeded()
    },
    onDown () {
      if (this.ignoreControls === true) return
      if (this.selectMessage === -1) {
        this.selectMessage = 0
      } else {
        this.selectMessage = this.selectMessage === this.darkwebMessages.length - 1 ? this.selectMessage : this.selectMessage + 1
      }
      this.scrollIntoViewIfNeeded()
    },
    async onEnter () {
      if (this.ignoreControls === true) return
      if (this.selectMessage === -1) {
        // this.newTweet()
      } else {
        this.showOption()
      }
    },
    onBack () {
      if (this.imgZoom !== undefined) {
        this.imgZoom = undefined
        return
      }
      if (this.ignoreControls === true) return
      if (this.selectMessage !== -1) {
        this.selectMessage = -1
      } else {
        this.$router.push({ name: 'menu' })
      }
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

.img-fullscreen {
  position: fixed;
  z-index: 999999;
  background-color: rgba(20, 20, 20, 0.8);
  left: 0;
  top: 0;
  right: 0;
  bottom: 0;
  display: flex;
  justify-content: center;
  align-items: center;
}

.img-fullscreen img {
  display: flex;
  max-width: 90vw;
  max-height: 95vh;
}

.dark-wrapper {
  height: 100%;
  background-color: #eeeeee;
  color: black;
  display: flex;
  flex-direction: column;
  overflow-y: auto;
}

.tweet-img {
  width: 322px;
  display: flex;
  justify-content: center;
}

.tweet-img img {
  border-radius: 1%;
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
  font-weight: 500;
}

.dark-message {
  font-size: 14px;
  color: 000;
  min-height: 36px;
  width: 98%;
  word-break: break-word;
}

.dark-message-img {
  border-radius: 5%;
  width: 100%;
  padding-left: 5px;
}

.dark-like-content {
  margin-top: 6px;
  display: flex;
  position: relative;
  justify-content: center;
  width: 100%;
  height: 24px;
  font-size: 12px;
  line-height: 24px;
  font-weight: 700;
}

.dark-like-content div {
  width: 80px;
}

.tweet_write{
    height: 56px;
    widows: 100%;
    background: #c0deed;
    display: flex;
    justify-content: space-around;
    align-items: center;
}

.tweet_write input{
    width: 75%;
    margin-left: 6%;
    border: none;
    outline: none;
    font-size: 16px;
    padding: 3px 12px;
    float: left;
    height: 36px;
    background-color: #ffffff;
    color: white;
    border-radius: 16px;
}

.tweet_write input::placeholder {
  color: #888;
}

.tweet_send{
  width: 32px;
  height: 32px;
  float: right;
  border-radius: 50%;
  background-color: #0084b4;
  margin-right: 12px;
  margin-bottom: 2px;
  color: white;
  line-height: 32px;
  text-align: center;
}

.elements::-webkit-scrollbar-track {
  box-shadow: inset 0 0 6px rgba(0,0,0,0.3);
  background-color: #a6a28c;
}

.elements::-webkit-scrollbar {
  width: 3px;
  background-color: transparent;
}

.elements::-webkit-scrollbar-thumb {
  background-color: #1da1f2;
}
</style>
