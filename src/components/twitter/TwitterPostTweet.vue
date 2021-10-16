<template>
  <div style="width: 330px; height: 100%;" class="background">
    <div class='tweet_write'>
        <!-- <textarea class="textarea-input" v-model.trim="message" v-autofocus :placeholder="LangString('APP_TWITTER_PLACEHOLDER_MESSAGE')"></textarea> -->
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
      modalopened: false
    }
  },
  computed: {
    ...mapGetters(['LangString'])
  },
  watch: {
  },
  methods: {
    ...mapActions(['twitterPostTweet']),
    async onEnter () {
      if (this.modalopened) return
      this.modalopened = true
      let scelte = [
        {id: 1, title: this.LangString('APP_TWITTER_POST_TWEET'), icons: 'fa-comment'},
        {id: 2, title: this.LangString('APP_TWITTER_POST_PICTURE'), icons: 'fa-camera'}
      ]
      let resp = await Modal.CreateModal({ scelte: scelte })
      if (resp.id === 1) {
        this.postTextTweet()
        this.modalopened = false
      } else if (resp.id === 2) {
        this.choosePicType()
      }
    },
    async choosePicType () {
      this.modalopened = true
      let scelte = [
        {id: 1, title: this.LangString('APP_CONFIG_LINK_PICTURE'), icons: 'fa-link'},
        {id: 2, title: this.LangString('APP_CONFIG_TAKE_PICTURE'), icons: 'fa-camera'}
      ]
      const resp = await Modal.CreateModal({ scelte: scelte })
      if (resp.id === 1) {
        Modal.CreateTextModal({ text: 'https://i.imgur.com/' }).then(valueText => {
          if (valueText.text !== '' && valueText.text !== undefined && valueText.text !== null && valueText.text !== 'https://i.imgur.com/') {
            this.twitterPostTweet({ message: valueText.text })
            this.modalopened = false
          }
        })
      } else if (resp.id === 2) {
        const pic = await this.$phoneAPI.takePhoto()
        if (pic && pic !== '') {
          this.twitterPostTweet({ message: pic })
          this.modalopened = false
        }
      } else {
        this.modalopened = false
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
      const rep = await this.$phoneAPI.getReponseText({ title: 'Digita il messaggio da inviare' })
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
