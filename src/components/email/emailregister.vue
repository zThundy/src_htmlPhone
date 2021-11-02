<template>
  <div class="phone_app">
    <InfoBare />

    <div class="splash">
      <img src="/html/static/img/icons_app/email.png">

      <div class="inputDiv">
        <input disabled v-model="localEmail" :placeholder="LangString('APP_EMAIL_REGISTER_PLACEHOLDER')"/>
      </div>
    </div>

  </div>
</template>

<script>
import { mapMutations, mapGetters } from 'vuex'

import Modal from '@/components/Modal/index.js'
import InfoBare from '@/components/InfoBare'

export default {
  name: 'email.register',
  components: { InfoBare },
  data () {
    return {
      ignoreControls: false,
      localEmail: ''
    }
  },
  computed: {
    ...mapGetters(['config', 'LangString', 'myEmail'])
  },
  methods: {
    ...mapMutations(['SETUP_MY_EMAIL']),
    onEnter () {
      if (this.ignoreControls) return
      this.ignoreControls = true
      // dopo i controlli metto le info nel input
      if (!this.localEmail) {
        // let select = document.querySelector('.inputDiv')
        Modal.CreateTextModal({
          limit: 25,
          title: this.LangString('APP_EMAIL_INSERT_EMAIL_TITLE'),
          color: 'rgb(216, 71, 49)'
        })
        .then(resp => {
          if (resp.text.length > 25) {
            this.$phoneAPI.sendErrorMessage(this.LangString('APP_EMAIL_ERROR_TOO_MANY_CHARS'))
          } else {
            if (!resp.text.includes(this.config.email_suffix)) {
              resp.text = resp.text + this.config.email_suffix
            }
            resp.text = resp.text.replace(' ', '_')
            this.localEmail = resp.text
          }
          this.ignoreControls = false
        })
        .catch(e => { this.ignoreControls = false })
      } else {
        this.createModal()
      }
    },
    onBackspace () {
      if (this.ignoreControls) {
        this.ignoreControls = false
        return
      }
      this.$router.push({ name: 'menu' })
    },
    async onRight () {
      this.createModal()
    },
    createModal () {
      this.ignoreControls = true
      var options = [
        { id: 1, title: this.LangString('APP_EMAIL_REGISTER_CHOICE_ONE'), icons: 'fa-pencil-alt' },
        { id: 2, title: this.LangString('APP_EMAIL_REGISTER_CHOICE_TWO'), icons: 'fa-check', color: 'green' },
        { id: 0, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' }
      ]
      Modal.CreateModal({ scelte: options }).then(resp => {
        switch (resp.id) {
          case 0:
            this.ignoreControls = false
            break
          case 1:
            this.localEmail = null
            this.ignoreControls = false
            break
          case 2:
            this.SETUP_MY_EMAIL(this.localEmail)
            this.$phoneAPI.registerEmail(this.localEmail)
            this.$router.push({ name: 'email' })
            this.ignoreControls = false
            break
        }
      })
    }
  },
  created () {
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
    this.$bus.$on('keyUpArrowRight', this.onRight)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpArrowRight', this.onRight)
  }
}
</script>

<style scoped>
.phone_app {
  background-color: rgb(216, 71, 49);
}

.splash {
  width: 100%;
  height: 100%;

  display: flex;
  justify-content: center;
  align-items: center;

  background-color: rgb(216, 71, 49);
}

img {
  animation-name: zoom;
  animation-duration: 1.5s;
  animation-fill-mode: forwards;
}

@keyframes zoom {
  0% {
    padding-bottom: 0px;
    width: 20%;
  }
  50% {
    padding-bottom: 0px;
    width: 40%;
  }
  100% {
    padding-bottom: 120%;
    width: 40%;
  }
}

.inputDiv {
  position: absolute;
  height: 50px;
  width: 100%;

  display: flex;
  align-content: center;
  align-items: center;
  justify-content: center;

  opacity: 0;

  animation-delay: 1.5s;

  animation-name: show;
  animation-duration: 0.8s;
  animation-fill-mode: forwards;
}

input {
  height: 50px;
  width: 90%;

  border-style: hidden;
  border-radius: 10px;

  text-align: center;
  background-color: rgb(235, 235, 235);
}

@keyframes show {
  0% {
    opacity: 0;
  }
  100% {
    opacity: 1;
  }
}
</style>
