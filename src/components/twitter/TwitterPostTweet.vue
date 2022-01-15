<template>
  <div style="width: 330px; height: 100%;" class="background">
    <div class='tweet_write'>
        <textarea class="textarea-input" v-model.trim="message" :placeholder="LangString('APP_TWITTER_PLACEHOLDER_MESSAGE')"></textarea>
        <i class="fa fa-pencil-alt" aria-hidden="true"></i>

        <div class="buttons">
          <span class='tweet_send'>{{ LangString('APP_TWITTER_BUTTON_ACTION_TWEETER') }}</span> 
          <span class='tweet_send_left'>{{ LangString('APP_TWITTER_BUTTON_ACTION_PICTURE') }}</span>
        </div>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'
import Modal from '@/components/Modal/index.js'

export default {
  components: {},
  data () {
    return {
      message: '',
      ignoreControls: false
    }
  },
  computed: {
    ...mapGetters(['LangString'])
  },
  watch: { },
  methods: {
    ...mapActions(['twitterPostTweet']),
    onEnter () {
      if (this.ignoreControls) return
      this.ignoreControls = true
      Modal.CreateModal({ scelte: [
        { id: 1, title: this.LangString('APP_TWITTER_POST_TWEET'), icons: 'fa-comment' },
        { id: 2, title: this.LangString('APP_TWITTER_POST_PICTURE'), icons: 'fa-camera' }
      ] })
      .then(resp => {
        switch(resp.id) {
          case 1:
            this.postTextTweet()
            this.ignoreControls = false
            break
          case 2:
            this.choosePicType()
            break
        }
      })
      .catch(e => { this.ignoreControls = false })
    },
    async choosePicType () {
      this.ignoreControls = true
      Modal.CreateModal({ scelte: [
        { id: 1, title: this.LangString('APP_CONFIG_LINK_PICTURE'), icons: 'fa-link' },
        { id: 2, title: this.LangString('APP_CONFIG_TAKE_PICTURE'), icons: 'fa-camera' }
      ] })
      .then(async resp => {
        switch(resp.id) {
          case 1:
            Modal.CreateTextModal({
              text: 'https://i.imgur.com/',
              title: this.LangString('TYPE_LINK')
            })
            .then(value => {
              this.twitterPostTweet({ message: value.text })
              this.ignoreControls = false
            })
            .catch(e => { this.ignoreControls = false })
            break
          case 2:
            this.$phoneAPI.takePhoto()
            .then(pic => {
              this.twitterPostTweet({ message: pic })
              this.ignoreControls = false
            })
            .catch(e => { this.ignoreControls = false })
            break
        }
      })
      .catch(e => { this.ignoreControls = false })
    },
    onBack () {
      if (this.ignoreControls) return
      this.$bus.$emit('twitterHome')
    },
    async postTextTweet () {
      this.ignoreControls = true
      Modal.CreateTextModal({
        title: this.LangString('TYPE_MESSAGE')
      })
      .then(resp => {
        if (resp !== undefined && resp.text !== undefined) {
          const message = resp.text.trim()
          if (message.length !== 0) {
            this.twitterPostTweet({ message })
            this.ignoreControls = false
          }
        }
      })
      .catch(e => { this.ignoreControls = false })
    }
  },
  created () {
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  // mounted () {
  // },
  beforeDestroy () {
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.background {
  background-color: rgb(255, 255, 255);
}

.tweet_write {
  margin-top: 40px;

  widows: 100%;
  position: fixed;
  display: flex;
  flex-direction: column;
  justify-content: space-around;
  align-items: flex-end;
  padding-left: 15px;
}

.tweet_write i {
  position: absolute;
  top: 40px;
  right: 15px;
  color: gray;
}

.tweet_write .textarea-input {
  align-self: center;
  margin-top: 20px;
  /*border: 5px solid rgb(20, 40, 65);*/
  outline: none;
  font-size: 16px;
  padding: 13px 16px;

  height: 200px;
  width: 300px;
  padding-left: 10px;

  background-color: #ffffff;
  color: white;
  border-radius: 16px;
  resize: none;
  color: #222;
  font-size: 18px;
}

.buttons {
  position: relative;
  display: flex;

  flex-direction: row;
  margin-top: 20px;
}

.tweet_send {
  width: 110px;
  height: 32px;

  border-radius: 14px;
  background-color: rgb(55, 161, 242);

  color: white;
  line-height: 32px;
  text-align: center;
  margin: 26px 20px;
  font-size: 16px;
}

.tweet_send_left{
  width: 110px;
  height: 32px;

  border-radius: 14px;
  background-color: rgb(55, 161, 242);

  color: white;
  line-height: 32px;
  text-align: center;
  margin: 26px 20px;
  font-size: 16px;
}
</style>
