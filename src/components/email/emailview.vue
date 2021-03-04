<template>
  <div class="phone_app">
    <PhoneTitle :title="LangString('APP_EMAIL_CHOOSEN_TITLE')" :backgroundColor="'rgb(216, 71, 49)'" />

    <div class="email-container">
      <div class="email-header">

        <table class="email-header-content">
          <tr colspan="2">
            <td class="email-header-content-title">{{ LangString("APP_EMAIL_READING_FROM_LABEL") }}</td>
            <td class="email-header-content-text">{{ currentEmail.sender }}</td>
          </tr>
          <tr colspan="2">
            <td class="email-header-content-title">{{ LangString("APP_EMAIL_READING_TO_LABEL") }}</td>
            <td class="email-header-content-text">{{ currentEmail.receiver }}</td>
          </tr>
          <tr colspan="2">
            <td class="email-header-content-title">{{ LangString("APP_EMAIL_READING_TITLE_LABEL") }}</td>
            <td class="email-header-content-text">{{ currentEmail.title }}</td>
          </tr>
        </table>

      </div>

      <div class="email-body">

        <table class="email-body-content">
          <tr colspan="2">
            <td class="email-body-content-title">{{ LangString("APP_EMAIL_READING_MESSAGE_LABEL") }}</td>
          </tr>
          <tr colspan="2">
            <td class="email-body-content-text">{{ currentEmail.message }}</td>
          </tr>
        </table>

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
      emailID: -1,
      currentEmail: []
    }
  },
  computed: {
    ...mapGetters([
      'LangString',
      'emails'
    ])
  },
  methods: {
    ...mapActions([]),
    onBackspace () {
      // history.back()
      this.$router.push({ name: 'email' })
    }
  },
  created () {
    // startup del component
    // this.email = this.$route.params.id
    this.currentEmail = this.$route.params.email
    // eventi
    this.$bus.$on('keyUpBackspace', this.onBackspace)
  },
  beforeDestroy () {
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

  height: 8%;
}

.email-body .email-body-content .email-body-content-text {
  color: black;

  display: flex;
  font-size: 17px;
}

/* /////////// */
/* EXTRA STUFF */
/* /////////// */

</style>
