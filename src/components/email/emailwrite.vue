<template>
  <div class="phone_app">
    <PhoneTitle :title="LangString('APP_EMAIL_WRITE_EMAIL')" :backgroundColor="'rgb(216, 71, 49)'" />

    <div class="email-container">
      <div class="email-header">

        <table class="email-header-content">
          <tr colspan="2">
            <td class="email-header-content-title">{{ LangString("APP_EMAIL_SENDING_FROM_LABEL") }}</td>
            <td class="email-header-content-text">{{ myEmail }}</td>
          </tr>
          <tr colspan="2">
            <td class="email-header-content-title">{{ LangString("APP_EMAIL_SENDING_TO_LABEL") }}</td>
            <td class="email-header-content-text" :class="{ select: currentSelect == 0 }" data-model='receiver' data-maxlength='25' :data-title="'Digita il destinatario (senza ' + config.email_suffix + ')'">
              <input disabled v-model="email.receiver" maxlength="25">
              <span class="bar"></span>
            </td>
          </tr>
          <tr colspan="2">
            <td class="email-header-content-title">{{ LangString("APP_EMAIL_SENDING_TITLE_LABEL") }}</td>
            <td class="email-header-content-text" :class="{ select: currentSelect == 1 }" data-model='title' data-maxlength='25' data-title="Digita l'oggetto della email">
              <input disabled type="text" v-model="email.title" :placeholder="LangString('APP_EMAIL_SENDING_TITLE_PLACEHOLDER')" maxlength="25">
              <span class="bar"></span>
            </td>
          </tr>
        </table>

      </div>

      <div class="email-body">

        <table class="email-body-content">
          <tr colspan="2">
            <td class="email-body-content-title">{{ LangString("APP_EMAIL_SENDING_MESSAGE_LABEL") }}</td>
          </tr>
          <tr colspan="2">
            <td class="email-body-content-text" :class="{ select: currentSelect == 2 }" data-model='message' data-maxlength='250' data-title="Digita il messaggio della email">
              <textarea disabled v-model="email.message" :class="{ select: currentSelect == 2 }" maxlength="250" />
              <!-- <span class="bar"></span> -->
            </td>
          </tr>
        </table>

      </div>

    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import PhoneTitle from './../PhoneTitle'
import Modal from '@/components/Modal/index.js'

export default {
  name: 'email',
  components: { PhoneTitle },
  data () {
    return {
      currentSelect: -1,
      ignoreControls: false,
      email: {
        transmitter: this.myEmail,
        receiver: '',
        title: '',
        message: '',
        pic: '/html/static/img/app_email/defaultpic.png'
      }
    }
  },
  computed: {
    ...mapGetters(['config', 'LangString', 'myEmail'])
  },
  methods: {
    ...mapActions([]),
    onBackspace () {
      if (this.ignoreControls === true) {
        this.ignoreControls = false
        return
      }
      this.$router.push({ name: 'email' })
    },
    onUp () {
      if (this.ignoreControls === true) return
      if (this.currentSelect === -1) return
      this.currentSelect = this.currentSelect - 1
    },
    onDown () {
      if (this.ignoreControls === true) return
      if (this.currentSelect === 2) return
      this.currentSelect = this.currentSelect + 1
    },
    onEnter () {
      if (this.ignoreControls === true) return
      let select = document.querySelector('.select')
      if (select !== null) {
        let options = {
          limit: parseInt(select.dataset.maxlength) || 64,
          text: this.email[select.dataset.model] || '',
          title: select.dataset.title || ''
        }
        // aspetto la risposta da phoneapi
        if (select.dataset.model === 'receiver') {
          this.createModal(select.dataset.model, options)
        } else {
          this.$phoneAPI.getReponseText(options).then(data => {
            if (data.text.length > select.dataset.maxlength) {
              this.$phoneAPI.sendErrorMessage('Non puoi digitare tutti questi caratteri in questo campo')
              return
            }
            this.email[select.dataset.model] = data.text
          })
        }
      }
    },
    async createModal (model, options) {
      this.ignoreControls = true
      var info = [
        { id: 1, title: this.LangString('APP_EMAIL_SENDING_TITLE_CHOICE_ONE'), icons: 'fa-user' },
        { id: 2, title: this.LangString('APP_EMAIL_SENDING_TITLE_CHOICE_TWO'), icons: 'fa-pencil-alt' }
      ]
      Modal.CreateModal({ scelte: info }).then(resp => {
        switch (resp.id) {
          case 1:
            this.$router.push({ name: 'email.choosecontact', params: { email: this.email } })
            this.ignoreControls = false
            break
          case 2:
            this.$phoneAPI.getReponseText(options).then(data => {
              if (!data.text.includes(this.config.email_suffix)) { data.text = data.text + this.config.email_suffix }
              this.email[model] = data.text
            })
            // dopo la risposta da phoneapi riattivo i controlli
            this.ignoreControls = false
            break
        }
      })
    },
    async onRight () {
      this.ignoreControls = true
      var info = [
        { id: 1, title: this.LangString('APP_EMAIL_SENDING_FINALIZE_CHOICE_ONE'), icons: 'fa-envelope' },
        { id: 2, title: this.LangString('APP_EMAIL_SENDING_FINALIZE_CHOICE_TWO'), icons: 'fa-trash', color: 'red' }
      ]
      Modal.CreateModal({ scelte: info }).then(resp => {
        switch (resp.id) {
          case 1:
            if (this.email.receiver && this.email.title && this.email.message) {
              this.$phoneAPI.sendEmail(this.email)
              this.$router.push({ name: 'email' })
            } else {
              this.$phoneAPI.sendErrorMessage('Compila prima tutti i campi')
            }
            this.ignoreControls = false
            break
          case 2:
            this.$router.push({ name: 'email' })
            this.ignoreControls = false
            break
        }
      })
    }
  },
  created () {
    if (this.$route.params.email && this.$route.params.contact) {
      this.email = this.$route.params.email
      this.email.receiver = this.$route.params.contact.email
    }
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
  }
}
</script>

<style scoped>
.email-container {
  height: 100%;
}

.email-header {
  display: flex;
  justify-content: left;

  flex-direction: column;

  height: 20%;
}

.email-header .email-header-content {
  width: 100%;
  height: 100%;
}

.email-header .email-header-content td {
  border-bottom: .1px solid rgb(224, 224, 224);
}

.email-header .email-header-content .email-header-content-title {
  color: grey;
  font-size: 15px;
  text-align: center;

  width: 25%;
}

.email-header .email-header-content .email-header-content-text {
  color: black;
  font-weight: bolder;

  font-size: 14px;
}

.email-header .email-header-content .email-header-content-text input {
  color: black;
  font-weight: bolder;

  font-size: 14px;
  border-style: hidden;

  width: 95%;
}

/* ////////// */
/* EMAIL BODY */
/* ////////// */

.email-body {
  position: relative;
  width: 100%;
  height: 80%;
}

.email-body .email-body-content {
  width: 97%;
  height: 100%;

  padding-left: 10px;
}

.email-body .email-body-content .email-body-content-title {
  color: grey;
  font-size: 15px;

  text-align: left;
  vertical-align: middle;

  height: 7%;
}

.email-body .email-body-content .email-body-content-text textarea {
  color: black;

  display: flex;
  font-size: 17px;
  width: 100%;
  height: 96%;

  border: 2px solid rgba(247, 68, 40, 0.001);

  resize: none;
  border-radius: 3%;
}

.email-body .email-body-content .email-body-content-text .select {
  border: 2px solid rgb(247, 68, 40);

  transition: 0.2s ease all;
}

/* /////////// */
/* EXTRA STUFF */
/* /////////// */

.bar {
  position: relative;
  display: block;

  top: 3px;
  width: 95%;
}

.bar:before, .bar:after {
  content: '';
  height: 2px;
  width: 0;
  bottom: 0;
  position: absolute;
  background: rgb(247, 68, 40);

  transition: 0.2s ease all;
}

.bar:before {
  left: 50%;
}

.bar:after {
  right: 50%;
}

/* active state */
.select input ~ .bar:before, .select input ~ .bar:after {
  width: 50%;
}

.select textarea ~ .bar:before, .select textarea ~ .bar:after {
  border: 1px solid rgb(247, 68, 40);
}
</style>
