<template>
  <div class='dark_container'>
    <!-- <textarea class="dark_textarea" v-model.trim="message" v-autofocus :placeholder="LangString('APP_TWITTER_PLACEHOLDER_MESSAGE')"></textarea> -->
    <textarea class="dark_textarea" v-model.trim="message" :placeholder="LangString('APP_DARKWEB_PLACEHOLDER_MESSAGE')"></textarea>

    <div class="dark_buttons_container">
      <table>
        <tbody>
          <tr>
            <td>
              <span class='dark_button_class'>{{ LangString('APP_DARKWEB_BUTTON_ACTION_MESSAGE') }}</span>
            </td>
            <td>
              <span class='dark_button_class'>{{ LangString('APP_DARKWEB_BUTTON_ACTION_PICTURE') }}</span>
            </td>
          </tr>
        </tbody>
      </table>
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
    ...mapActions(['darkwebPostMessage']),
    async onEnter () {
      if (this.modalopened) return
      this.modalopened = true
      let resp = await Modal.CreateModal({ scelte: [
        {id: 1, title: this.LangString('APP_DARKWEB_POST_MESSAGE'), icons: 'fa-comment'},
        {id: 2, title: this.LangString('APP_DARKWEB_POST_PICTURE'), icons: 'fa-camera'}
      ] })
      if (resp.id === 1) {
        this.postTextTweet()
        this.modalopened = false
      } else if (resp.id === 2) {
        const pic = await this.$phoneAPI.takePhoto()
        if (pic && pic !== '') {
          this.modalopened = false
          this.darkwebPostMessage({ message: pic, mine: 1 })
        }
      }
    },
    onBack () {
      if (this.modalopened) {
        this.modalopened = false
      } else {
        this.$bus.$emit('darkwebHome')
      }
    },
    async postTextTweet () {
      const rep = await this.$phoneAPI.getReponseText({ title: 'A cosa stai pensando?' })
      if (rep !== undefined && rep.text !== undefined) {
        const message = rep.text.trim()
        if (message.length !== 0) {
          this.darkwebPostMessage({ message, mine: 1 })
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
  background: #dfdfdf;
}

.dark_container {
  position: relative;
  width: 100%;
  text-align: center;
}

.dark_textarea {
  margin-top: 20px;
  align-self: center;
  border: none;
  outline: none;
  font-size: 16px;
  padding: 13px 16px;

  height: 200px;
  width: 300px;
  
  margin-left: auto;
  margin-right: auto;

  background-color: #e8e8e8;
  color: white;
  border-radius: 16px;
  resize: none;
  color: #222;
  font-size: 20px;
}

.dark_buttons_container {
  width: 100%;
  height: 80px;
  margin-top: 30px;
}

.dark_button_class {
  align-self: flex-end;
  width: 120px;
  height: 32px;
  float: right;

  border-radius: 16px;
  background-color: rgb(131, 131, 131);
  color: white;
  
  line-height: 32px;
  text-align: center;
  margin: 26px 20px;
  font-size: 16px;
}

/*
.dark_button_class_left {
  align-self: flex-start;
  position: absolute;
  width: 120px;
  height: 32px;
  border-radius: 16px;
  background-color: rgb(131, 131, 131);

  margin-left: 12px;
  top: 156px;

  color: white;
  line-height: 32px;
  text-align: center;
  margin: 26px 20px;
  font-size: 16px;
}
*/
</style>
