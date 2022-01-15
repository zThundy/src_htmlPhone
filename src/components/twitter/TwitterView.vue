<template>
  <div style="height: auto;">

    <div class="phone_fullscreen_img" v-if="imgZoom !== undefined" @click.stop="imgZoom = undefined">
      <img :src="imgZoom" />
    </div>

    <div class="tweets-wrapper" ref="elementsDiv">
      <div class="tweet" v-for='(tweet, key) in tweets' :key="tweet.id" :class="{ select: key === selectMessage }">
        <div class="tweet-img">
          <img :src="tweet.authorIcon || 'html/static/img/app_twitter/default_profile.png'" width="40" height="40"/>
        </div>
        
        <div class="tweet-content">
          <div class="tweet-head">
            <div class="tweet-head-author">{{ tweet.author }}</div>
            <div class="tweet-head-time">{{ formatTime(tweet.time) }}</div>
          </div>

          <div class="tweet-message">
            <template v-if="!isImage(tweet.message)">{{ formatEmoji(tweet.message) }}</template>
            <img v-else :src="tweet.message" class="tweet-attachement-img">
          </div>

          <div class="tweet-like">
            <div class="item reply">
              <i class="fa fa-comment-o" aria-hidden="true"/>
            </div>
            
            <div class="item">
              <i class="fa fa-share-square-o" aria-hidden="true"/>
            </div>

            <div v-if="tweet.has_like" class="item svgdislike">
              <i class="fa fa-heart" aria-hidden="true"/>
              <span>{{ tweet.likes }}</span>
            </div>

            <div v-else class="svglike">
              <i class="fa fa-heart-o" aria-hidden="true"/>
              <span>{{ tweet.likes }}</span>
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
      selectMessage: -1,
      ignoreControls: false,
      imgZoom: undefined
    }
  },
  computed: {
    ...mapGetters([
      'tweets',
      'account',
      'LangString'
    ])
  },
  watch: { },
  methods: {
    ...mapActions([
      'twitterLogin',
      'twitterPostTweet',
      'twitterToogleLike'
    ]),
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
    this.$phoneAPI.twitter_getTweets(this.account.username, this.account.password)
    // login the user on first launch of the app
    this.$phoneAPI.twitter_login(this.account.username, this.account.password)
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
