<template>
  <div style="height: auto;">

    <div class="phone_fullscreen_img" v-if="imgZoom !== undefined" @click.stop="imgZoom = undefined">
      <img :src="imgZoom" />
    </div>

    <div class="tweets-wrapper" ref="elementsDiv">
      <div class="tweet" v-for='(tweet, key) in tweets' 
        v-bind:key="tweet.id"
        v-bind:class="{ select: key === selectMessage}"
      >
        <div class="tweet-img">
          <img :src="tweet.authorIcon || 'html/static/img/app_twitter/default_profile.png'" width="40" height="40"/>
        </div>
        
        <div class="tweet-content">
          <div class="tweet-head">
            <div class="tweet-head-author">{{ tweet.author }}</div>
            <div class="tweet-head-time">{{ formatTime(tweet.time) }}</div>
          </div>

          <div class="tweet-message">
            <!-- <template v-if="!isImage(tweet.message)">{{ tweet.message }}</template> -->
            <template v-if="!isImage(tweet.message)">{{ formatEmoji(tweet.message) }}</template>
            <img v-else :src="tweet.message" class="tweet-attachement-img">
          </div>

          <div class="tweet-like">
            <div class="item reply">
              <i class="fa fa-comment-o" aria-hidden="true"/>
              <!-- <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"><path fill="none" d="M0 0h24v24H0V0z"/><path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm0 14H6l-2 2V4h16v12z"/></svg> -->
            </div>
            
            <div class="item">
              <i class="fa fa-share-square-o" aria-hidden="true"/>
              <!-- <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"><path d="M0 0h24v24H0z" fill="none"/><path d="M7 7h10v3l4-4-4-4v3H5v6h2V7zm10 10H7v-3l-4 4 4 4v-3h12v-6h-2v4z"/></svg> -->
            </div>

            <div v-if="tweet.has_like" class="item svgdislike">
              <i class="fa fa-heart" aria-hidden="true"/>
              <!-- <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"><path d="M0 0h24v24H0z" fill="none"/><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg> -->
              <span>{{ tweet.likes }}</span>
            </div>

            <div v-else class="svglike">
              <i class="fa fa-heart-o" aria-hidden="true"/>
              <!-- <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"><path d="M0 0h24v24H0z" fill="none"/><path d="M16.5 3c-1.74 0-3.41.81-4.5 2.09C10.91 3.81 9.24 3 7.5 3 4.42 3 2 5.42 2 8.5c0 3.78 3.4 6.86 8.55 11.54L12 21.35l1.45-1.32C18.6 15.36 22 12.28 22 8.5 22 5.42 19.58 3 16.5 3zm-4.4 15.55l-.1.1-.1-.1C7.14 14.24 4 11.39 4 8.5 4 6.5 5.5 5 7.5 5c1.54 0 3.04.99 3.57 2.36h1.87C13.46 5.99 14.96 5 16.5 5c2 0 3.5 1.5 3.5 3.5 0 2.89-3.14 5.74-7.9 10.05z"/></svg> -->
              <span>{{ tweet.likes }}</span>
            </div>
            
            <!--
            <div class="item">
              <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"><path fill="none" d="M0 0h24v24H0V0z"/><path d="M18 16.08c-.76 0-1.44.3-1.96.77L8.91 12.7c.05-.23.09-.46.09-.7s-.04-.47-.09-.7l7.05-4.11c.54.5 1.25.81 2.04.81 1.66 0 3-1.34 3-3s-1.34-3-3-3-3 1.34-3 3c0 .24.04.47.09.7L8.04 9.81C7.5 9.31 6.79 9 6 9c-1.66 0-3 1.34-3 3s1.34 3 3 3c.79 0 1.5-.31 2.04-.81l7.12 4.16c-.05.21-.08.43-.08.65 0 1.61 1.31 2.92 2.92 2.92s2.92-1.31 2.92-2.92-1.31-2.92-2.92-2.92z"/></svg>
            </div>
            -->
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
      selectMessage: -1,
      ignoreControls: false,
      imgZoom: undefined
    }
  },
  computed: {
    ...mapGetters(['tweets', 'twitterUsername', 'twitterPassword', 'LangString'])
  },
  watch: { },
  methods: {
    ...mapActions(['twitterLogin', 'twitterPostTweet', 'twitterToogleLike']),
    ...mapMutations(['CHANGE_BRIGHTNESS_STATE']),
    formatEmoji (message) {
      return this.$phoneAPI.convertEmoji(message)
    },
    async showOption () {
      this.ignoreControls = true
      const tweet = this.tweets[this.selectMessage]
      let scelte = [
        { id: 1, title: this.LangString('APP_TWITTER_LIKE'), icons: 'fa-heart' },
        { id: 2, title: this.LangString('APP_TWITTER_REPLY'), icons: 'fa-retweet' },
        { id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' }
      ]
      if (this.isImage(tweet.message)) {
        scelte = [{ id: 3, title: this.LangString('APP_MESSAGE_ZOOM_IMG'), icons: 'fa-search' }, ...scelte]
      }
      Modal.CreateModal({ scelte: scelte })
      .then(resp => {
        this.ignoreControls = false
        switch (resp.id) {
          case 1:
            this.twitterToogleLike({ tweetId: tweet.id })
            break
          case 2:
            this.reply(tweet)
            break
          case 3:
            this.imgZoom = tweet.message
            this.CHANGE_BRIGHTNESS_STATE(false)
            break
        }
      })
      .catch(e => { this.ignoreControls = false })
    },
    isImage (mess) {
      return this.$phoneAPI.isLink(mess)
    },
    reply (tweet) {
      const authorName = tweet.author
      this.ignoreControls = true
      Modal.CreateTextModal({
        title: this.LangString('TYPE_MESSAGE'),
        text: `@${authorName}`
      })
      .then(resp => {
        if (resp !== undefined && resp.text !== undefined) {
          const message = resp.text.trim()
          if (message.length !== 0) {
            this.twitterPostTweet({ message })
          }
        }
      })
      .catch(e => { this.ignoreControls = false })
    },
    resetScroll () {
      this.$nextTick(() => {
        let elem = document.querySelector('#tweets')
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
        this.selectMessage = 0
      } else {
        this.selectMessage = this.selectMessage === 0 ? 0 : this.selectMessage - 1
      }
      this.scrollIntoView()
    },
    onDown () {
      if (this.ignoreControls) return
      if (this.selectMessage === -1) {
        this.selectMessage = 0
      } else {
        this.selectMessage = this.selectMessage === this.tweets.length - 1 ? this.selectMessage : this.selectMessage + 1
      }
      this.scrollIntoView()
    },
    async onEnter () {
      if (this.ignoreControls) return
      if (this.selectMessage !== -1) {
        this.showOption()
      }
    },
    onBack () {
      if (this.imgZoom !== undefined) {
        this.imgZoom = undefined
        this.CHANGE_BRIGHTNESS_STATE(true)
        return
      }
      if (this.ignoreControls) return
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
    // faccio la request a phoneapi per i tweets
    this.$phoneAPI.twitter_getTweets(this.twitterUsername, this.twitterPassword)
    // creo gli eventi
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  mounted () { },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.svgdislike {
  fill: red;
  color: red;
}

.tweets-wrapper {
  height: 100%;
  /* background-color: #DBF0F4; */
  color: black;
  display: flex;
  flex-direction: column;
  overflow-y: hidden;

  background-color: rgb(255, 255, 255);
}

.tweet {
  /* background-color: #DBF0F4; */
  background-color: rgb(255, 255, 255);
  flex: 0 0 auto;
  width: 100%;
  display: flex;
  flex-direction: row;
  border-bottom: rgb(110, 118, 125) 1px solid;
  padding-top: 6px;

  color: rgb(0, 0, 0);
}

.tweet.select {
  background-color: rgba(110, 118, 125, 0.308);
}

.tweet-img {
  width: 70px;
  display: flex;
  justify-content: center;
}

.tweet-img img {
  object-fit: cover;
  border-radius: 50%;
}

.tweet-content {
  width: 260px;
}

.tweet-head {
  padding-bottom: 4px;
  font-size: 14px;
  display: flex;
  flex-direction: row;
  font-weight: 700;
}

.tweet-head-author {
  width: auto;
}

.tweet-head-time {
  padding-top: 7px;
  padding-left: 5px;

  font-size: 10px;
  text-align: right;

  color: rgb(143, 143, 143);
}

.tweet-message {
  font-size: 12px;
  min-height: 36px;
  word-break: break-word;
}

.tweet-attachement-img {
  /* border-radius: 50px; */
  border: 1px solid black;
  width: 96%;
}

.tweet-like {
  margin-top: 4px;
  margin-bottom: 4px;
  color: rgb(110, 118, 125);
  display: flex;
  width: 100%;
  height: 24px;
  line-height: 24px;
  font-weight: 700;
}

.tweet-like div {
  margin-left: auto;
  margin-right: auto;
}

.tweet-like i {
  font-size: 15px;
}

.tweet-like span {
  font-size: 12px;
}

/*
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
*/
</style>
