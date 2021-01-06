<template>
  <div class="phone_app">
    <InfoBare />

    <div class="splash">
      <img src="/html/static/img/icons_app/email.png">

      <div class="inputDiv" data-maxlength="25">
        <input disabled maxlength="25" v-model="localEmail" :placeholder="IntlString('APP_EMAIL_REGISTER_PLACEHOLDER')"/>
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
    ...mapGetters(['IntlString', 'myEmail'])
  },
  methods: {
    ...mapMutations(['SETUP_MY_EMAIL']),
    onEnter () {
      if (this.ignoreControls) return
      this.ignoreControls = true
      // dopo i controlli metto le info nel input
      if (!this.localEmail) {
        let select = document.querySelector('.inputDiv')
        let options = { limit: parseInt(select.dataset.maxlength) || 64 }
        this.$phoneAPI.getReponseText(options).then(data => {
          if (data.text.length > 25) {
            this.$phoneAPI.sendErrorMessage('Non puoi digitare tutti questi caratteri in questo campo')
          } else {
            if (!data.text.includes('@code.it')) { data.text = data.text + '@code.it' }
            data.text = data.text.replace(' ', '_')
            this.localEmail = data.text
          }
          this.ignoreControls = false
        })
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
    createModal () {
      this.ignoreControls = true
      var options = [
        { id: 1, title: this.IntlString('APP_EMAIL_REGISTER_CHOICE_ONE'), icons: 'fa-pencil-square-o' },
        { id: 2, title: this.IntlString('APP_EMAIL_REGISTER_CHOICE_TWO'), icons: 'fa-check', color: 'green' },
        { id: 0, title: this.IntlString('CANCEL'), icons: 'fa-undo', color: 'red' }
      ]
      Modal.CreateModal({ choix: options }).then(resp => {
        switch (resp.id) {
          case 0:
            this.ignoreControls = false
            break
          case 1:
            this.localEmail = null
            this.onEnter()
            this.ignoreControls = false
            break
          case 2:
            this.SETUP_MY_EMAIL(this.localEmail)
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
  },
  beforeDestroy () {
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
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
  border-radius: 5%;

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
