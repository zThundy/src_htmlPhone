<template>
  <div class="phone_app">
    <PhoneTitle v-if="currentModule === 0" :title="IntlString('APP_EMAIL_TITLE')" :backgroundColor="'rgb(216, 71, 49)'" />
    <PhoneTitle v-if="currentModule === 1" :title="IntlString('APP_EMAIL_SECOND_TITLE')" :backgroundColor="'rgb(216, 71, 49)'" />

    <div class="emails-container">

      <div v-if="currentModule === 0">

        <div class="email-container" v-for="(email, key) of emails" :key="key" :class="{ select: key === currentSelect }">

          <div class="email-timestamp">{{ formatTime(email.time) }}</div>

          <div class="email-header">
            <i class="fa fa-arrow-circle-right"/>
            <i class="email-text">{{ IntlString('APP_EMAIL_RECEIVER_LABEL') }} {{ email.receiver }}</i>
          </div>

          <div class="email-body">
            <i class="email-text">{{ getCorrectMessage(email.title) }}</i>
          </div>

          <div class="email-pic">
            <img :src="getEmailPic(email)"/>
          </div>

          <div class="email-divider"></div>

          
          <!--

            {{ email.message }}

            <div class="email-sender">{{ IntlString('APP_EMAIL_SENDER_LABEL') }}: {{ email.sender }}</div>
            <div class="email-receiver">{{ IntlString('APP_EMAIL_RECEIVER_LABEL') }}: {{ email.receiver }}</div>

            <div class="email-message">{{ IntlString('APP_EMAIL_MESSAGE_LABEL') }}: {{ email.message }}</div>

            <tr>
              <td class="email-headers" align="right">
                {{ IntlString('APP_EMAIL_RECEIVER_LABEL') }}: {{ email.receiver }}
              </td>
            </tr>
          -->
          
        </div>

        <div class="email-write-dot">
          <i class="email-write-icon fa fa-pencil"></i>
        </div>

      </div>

      <div v-if="currentModule === 1">

        <div class="email-container" v-for="(email, key) of sentEmails" :key="key" :class="{ select: key === currentSelect }">

          <div class="email-timestamp">{{ formatTime(email.time) }}</div>

          <div class="email-header">
            <i class="fa fa-arrow-circle-down"/>
            <i class="email-text">{{ IntlString('APP_EMAIL_SENDER_LABEL') }} {{ email.sender }}</i>
          </div>

          <div class="email-body">
            <i class="email-text">{{ getCorrectMessage(email.title) }}</i>
          </div>

          <div class="email-pic">
            <img :src="getEmailPic(email)"/>
          </div>

          <div class="email-divider"></div>

        </div>


        <div class="email-write-dot">
          <i class="email-write-icon fa fa-pencil"></i>
        </div>

      </div>

    </div>

    <div class="email-footer">
      <div class="email-footer-item" :class="{ select: 0 === currentModule }">
        <i class="fa fa-envelope"></i>
      </div>
      <div class="email-footer-item" :class="{ select: 1 === currentModule }">
        <i class="fa fa-envelope-open"></i>
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
      ignoreControl: false,
      currentModule: 0
    }
  },
  computed: {
    ...mapGetters([
      'IntlString',
      'emails',
      'sentEmails'
    ])
  },
  methods: {
    ...mapActions([
      'deleteEmail'
    ]),
    scrollIntoViewIfNeeded () {
      this.$nextTick(() => {
        const elem = this.$el.querySelector('.select')
        if (elem !== null) {
          elem.scrollIntoViewIfNeeded()
        }
      })
    },
    onBackspace () {
      if (this.ignoreControl) {
        this.ignoreControl = false
        return
      }
      if (this.currentSelect !== -1) {
        this.currentSelect = -1
        return
      }
      this.$router.push({ name: 'menu' })
    },
    onEnter () {
      if (this.ignoreControl) return
      if (this.currentSelect === -1) return
      this.openModal()
    },
    async onRight () {
      if (this.ignoreControl) return
      this.changeModule('right', this.currentModule + 1)
    },
    async onLeft () {
      if (this.ignoreControl) return
      this.changeModule('left', this.currentModule - 1)
    },
    onUp () {
      if (this.ignoreControl) return
      if (this.currentSelect === -1) return
      this.currentSelect = this.currentSelect - 1
      this.scrollIntoViewIfNeeded()
    },
    onDown () {
      if (this.ignoreControl) return
      if (this.currentSelect === this.emails.length - 1) return
      this.currentSelect = this.currentSelect + 1
      this.scrollIntoViewIfNeeded()
    },
    changeModule (type, module) {
      if (type === 'left' && this.currentModule === 0) return
      if (type === 'right' && this.currentModule === 1) return
      this.requestAllEmails()
      this.currentModule = module
    },
    openModal () {
      this.ignoreControl = true
      var info = [
        { id: 3, title: this.IntlString('APP_EMAIL_VIEW'), icons: 'fa-envelope-open' },
        { id: 1, title: this.IntlString('APP_EMAIL_WRITE_EMAIL'), icons: 'fa-pencil-square-o' }
      ]
      if (this.currentSelect !== -1) {
        info = [
          ...info,
          { id: 2, title: this.IntlString('APP_EMAIL_DELETE_EMAIL'), icons: 'fa-trash' },
          { id: -1, title: this.IntlString('CANCEL'), color: 'red', icons: 'fa-undo' }
        ]
      }
      Modal.CreateModal({ choix: info }).then(response => {
        switch (response.id) {
          case 1:
            this.$router.push({ name: 'email.write' })
            this.ignoreControl = false
            break
          case 2:
            this.deleteEmail(this.currentSelect)
            this.ignoreControl = false
            break
          case 3:
            if (this.currentModule === 0) {
              this.$router.push({ name: 'email.view', params: { email: this.emails[this.currentSelect] } })
            } else if (this.currentModule === 1) {
              this.$router.push({ name: 'email.view', params: { email: this.sentEmails[this.currentSelect] } })
            }
            break
          case -1:
            this.ignoreControl = false
        }
      })
    },
    requestAllEmails () {
      this.$phoneAPI.requestSentEmails(this.myEmail)
      this.$phoneAPI.requestMyEmail()
    },
    getEmailPic (sender) {
      if (sender.pic) {
        return sender.pic
      }
      return '/html/static/img/app_email/defaultpic.png'
    },
    getCorrectMessage (message) {
      var tempMessage = message
      if (message.length >= 35) {
        tempMessage = tempMessage.substr(0, 35) + '...'
      }
      return tempMessage
    },
    formatTime (time) {
      const dateObject = new Date(time)
      var hours = dateObject.getHours()
      var minutes = dateObject.getMinutes()
      if (minutes < 10) minutes = '0' + minutes
      if (hours < 10) hours = '0' + hours
      return hours + ':' + minutes
    }
  },
  created () {
    this.requestAllEmails()
    // dopo aver richiesto le informazioni, creo gli eventi
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpArrowDown', this.onDown)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpArrowDown', this.onDown)
  }
}
</script>

<style scoped>
.emails-container {
  overflow: auto;
  position: relative;

  height: 100%;
  width: 100%;
}

.email-footer {
  position: sticky;
  border-top: 1px solid #CCC;
  height: 56px;
  display: flex;
  width: 100%;
}

.email-footer-item {
  flex-grow: 1;
  flex-basis: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  color: #959595;
}

.email-footer-item.select {
  color: rgb(247, 68, 40);;
}

.email-container {
  overflow: hidden;
  width: 100%;
}

.email-header {
  font-size: 15px;

  position: absolute;
  left: 19%;
  padding-top: 3%;
  justify-content: left;
}

.email-body {
  font-size: 15px;

  position: absolute;
  left: 22%;
  padding-top: 10%;
  width: 78%;
  justify-content: left;
}

.email-header .email-text {
  position: relative;
  font-weight: bold;

  font-size: 12px;
  font-family: SanFrancisco;
  font-style: normal;

  bottom: 2px;
}

.email-timestamp {
  position: absolute;

  padding-top: 36px;
  width: 97%;

  display: flex;
  justify-content: flex-end;

  font-size: 10px;
  font-family: SanFrancisco;
  font-style: normal;
}

.email-body .email-text {
  font-size: 12px;
  font-family: SanFrancisco;
  font-style: normal;
}

.select {
  background-color: rgb(233, 233, 233);
}

/* .email-elements { } */

.email-divider {
  height: 20px;
}

.email-pic {
  position: relative;
  left: 8px;
  top: 8px;

  overflow: auto;
}

.email-pic img {
  object-fit: cover;
  border-radius: 50%;
  border: .5px solid rgb(180, 180, 180);

  height: 50px;
  width: 50px;

  overflow: hidden;
  display: flex;
  justify-content: center;
  align-items: center;
}

.email-write-dot {
  position: fixed;

  width: 60px;
  height: 60px;
  background-color: rgb(247, 68, 40);
  bottom: 23%;
  right: 28%;

  box-shadow: 0 0 10px rgba(0, 0, 0, 0.6);
  /* box-shadow: 0 12px 10px -10px black; */

  border-radius: 50%;
}

.email-write-dot .email-write-icon {
  color: white;
  padding-top: 13px;
  font-size: 30px;
  display: flex;
  justify-content: center;
}
</style>
