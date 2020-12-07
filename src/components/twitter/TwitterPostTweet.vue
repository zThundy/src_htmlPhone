<template>
  <div style="width: 326px; height: 743px;" class="phone_content">
    <div class='tweet_write'>
        <!-- <textarea class="textarea-input" v-model.trim="message" v-autofocus :placeholder="IntlString('APP_TWITTER_PLACEHOLDER_MESSAGE')"></textarea> -->
        <textarea class="textarea-input" v-model.trim="message" :placeholder="IntlString('APP_TWITTER_PLACEHOLDER_MESSAGE')"></textarea>

        <span class='tweet_send'>{{ IntlString('APP_TWITTER_BUTTON_ACTION_TWEETER') }}</span> 
        <span class='tweet_send_left'>{{ IntlString('APP_TWITTER_BUTTON_ACTION_PICTURE') }}</span>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'
import Modal from '@/components/Modal/index.js'
import PhoneAPI from './../../PhoneAPI'

export default {
  components: {},
  data () {
    return {
      message: '',
      modalopened: false
    }
  },
  computed: {
    ...mapGetters(['IntlString'])
  },
  watch: {
  },
  methods: {
    ...mapActions(['twitterPostTweet']),
    async onEnter () {
      if (this.modalopened) return
      this.modalopened = true
      let choix = [
        {id: 1, title: this.IntlString('APP_TWITTER_POST_TWEET'), icons: 'fa-comment'},
        {id: 2, title: this.IntlString('APP_TWITTER_POST_PICTURE'), icons: 'fa-camera'}
      ]
      let resp = await Modal.CreateModal({ choix: choix })
      if (resp.id === 1) {
        this.postTextTweet()
        this.modalopened = false
      } else if (resp.id === 2) {
        const newAvatar = await PhoneAPI.takePhoto()
        if (newAvatar.url !== undefined || newAvatar.url !== null) {
          this.modalopened = false
          this.twitterPostTweet({ message: newAvatar.url })
        }
      }
    },
    onBack () {
      if (this.modalopened) {
        this.modalopened = false
      } else {
        this.$bus.$emit('twitterHome')
      }
    },
    async postTextTweet () {
      const rep = await this.$phoneAPI.getReponseText({ })
      if (rep !== undefined && rep.text !== undefined) {
        const message = rep.text.trim()
        if (message.length !== 0) {
          this.twitterPostTweet({ message })
        }
      }
    }
  },
  created () {
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  async mounted () {
  },
  beforeDestroy () {
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.phone_content {
  background: #DBF0F4;
}

.tweet_write{
  widows: 100%;
  position: fixed;
  display: flex;
  flex-direction: column;
  justify-content: space-around;
  align-items: flex-end;
  padding-left: 15px;
}

.tweet_write .textarea-input{
  align-self: center;
  margin-top: 20px;
  border: none;
  outline: none;
  font-size: 16px;
  padding: 13px 16px;

  height: 236px;
  width: 300px;
  padding-left: 10px;

  background-color: #ffffff;
  color: white;
  border-radius: 16px;
  resize: none;
  color: #222;
  font-size: 18px;
}

.tweet_send{
  align-self: flex-end;
  width: 120px;
  height: 32px;
  float: right;
  border-radius: 16px;
  background-color: rgb(29, 161, 242);
  margin-right: 12px;
  margin-bottom: 2px;
  color: white;
  line-height: 32px;
  text-align: center;
  margin: 26px 20px;
  font-size: 16px;
}

.tweet_send:hover {
  cursor: pointer;
  background-color: #0084b4;
}

.tweet_send_left{
  align-self: flex-start;
  position: absolute;
  width: 120px;
  height: 32px;
  border-radius: 16px;
  background-color: rgb(29, 161, 242);

  margin-left: 12px;
  top: 256px;

  color: white;
  line-height: 32px;
  text-align: center;
  margin: 26px 20px;
  font-size: 16px;
}

.tweet_send_left:hover {
  cursor: pointer;
  background-color: #0084b4;
}
</style>
