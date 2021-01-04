<template>
  <div class="phone_app">
    <PhoneTitle :title="IntlString('APP_EMAIL_TITLE')" :backgroundColor="'rgb(216, 71, 49)'" />

    <div class="emails-container">

        <div class="email-body" v-for="(email, key) of emails" :key="key">

        <div class="email-elements">
          <table align="center" border="1" cellpadding="0" cellspacing="0" style="border-collapse: collapse;">
            <tr>
              <td align="left">
                {{ IntlString('APP_EMAIL_SENDER_LABEL') }}: {{ email.sender }}
              </td>
            </tr>
            <tr>
              <td align="right">
                {{ IntlString('APP_EMAIL_RECEIVER_LABEL') }}: {{ email.receiver }}
              </td>
            </tr>
            <tr>
              <td>
                {{ email.message }}
              </td>
            </tr>
          </table>
        </div>
        
        <!--
        <div class="email-sender">{{ IntlString('APP_EMAIL_SENDER_LABEL') }}: {{ email.sender }}</div>
        <div class="email-receiver">{{ IntlString('APP_EMAIL_RECEIVER_LABEL') }}: {{ email.receiver }}</div>

        <div class="email-message">{{ IntlString('APP_EMAIL_MESSAGE_LABEL') }}: {{ email.message }}</div>
        -->
        
      </div>

    </div>

  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import PhoneTitle from './../PhoneTitle'
// import Modal from '@/components/Modal/index.js'

export default {
  name: 'email',
  components: { PhoneTitle },
  data () {
    return {
      currentSelect: -1
    }
  },
  computed: {
    ...mapGetters([
      'IntlString',
      'emails',
      'myEmail'
    ])
  },
  methods: {
    ...mapActions([]),
    scrollIntoViewIfNeeded () {
      this.$nextTick(() => {
        const elem = this.$el.querySelector('.select')
        if (elem !== null) {
          elem.scrollIntoViewIfNeeded()
        }
      })
    },
    onBackspace () {
      this.$router.push({ name: 'menu' })
    },
    onEnter () {
      if (this.currentSelect === -1) return
      this.computedApps[this.currentSelect] = true
      // qui uso questo trick per aggiornare
      this.currentSelect = this.currentSelect - 1
      this.currentSelect = this.currentSelect + 1
    },
    async onRight () {
      console.log('right')
    },
    onUp () {
      if (this.currentSelect === -1) return
      this.currentSelect = this.currentSelect - 1
      this.scrollIntoViewIfNeeded()
    },
    onDown () {
      if (this.currentSelect === this.emails.length - 1) return
      this.currentSelect = this.currentSelect + 1
      this.scrollIntoViewIfNeeded()
    }
  },
  created () {
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpArrowDown', this.onDown)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpArrowDown', this.onDown)
  }
}
</script>

<style scoped>
.emails-container {
  position: relative;
  height: 100%;
}

.email-body {
  background-color: rgb(185, 185, 185);
  height: 100px;
  padding-top: 5px;
}

.email-elements {
  width: 100%;
}

tr {
  width: 100%;
}

.line {
  position: relative;

  width: 100%;
  height: 1px;
  top: 64px;
  background-color: gray;
}
</style>
