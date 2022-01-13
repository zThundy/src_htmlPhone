<template>
  <div style="width: 330px; height: 100%;" class='content'>
    <component v-bind:is="state"/>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import Modal from '@/components/Modal'

import "./twitter_account/style.css"

import MENU from "./twitter_account/TwitterAccountLogin.vue"
import NEW_ACCOUNT from "./twitter_account/TwitterAccountNew.vue"
import NOTIFICATION from "./twitter_account/TwitterAccountNotifications.vue"
import ACCOUNT from "./twitter_account/TwitterAccountMain.vue"

const STATES = Object.freeze({ MENU, NEW_ACCOUNT, LOGIN: 2, ACCOUNT, NOTIFICATION })

export default {
  name: 'twitter',
  components: {},
  data () {
    return {
      STATES,
      state: STATES.MENU,
      localAccount: {
        username: '',
        password: '',
        passwordConfirm: '',
        avatarUrl: '/html/static/img/app_twitter/default_profile.png'
      },
      notification: 0,
      notificationSound: false,
      ignoreControls: false
    }
  },
  computed: {
    ...mapGetters(['LangString', 'twitterUsername', 'twitterPassword', 'twitterAvatarUrl', 'twitterNotification', 'twitterNotificationSound']),
    isLogin () {
      return this.twitterUsername !== undefined && this.twitterUsername !== ''
    },
    validAccount () {
      return this.localAccount.username.length >= 4 && this.localAccount.password.length >= 6 && this.localAccount.password === this.localAccount.passwordConfirm
    }
  },
  methods: {
    ...mapActions([
      'twitterLogin',
      'twitterChangePassword',
      'twitterLogout',
      'twitterSetAvatar',
      'twitterCreateNewAccount',
      'setTwitterNotification',
      'setTwitterNotificationSound'
    ]),
    onUp () {
      if (this.ignoreControls) return
      let select = document.querySelector('.group.select')
      if (select === null) {
        select = document.querySelector('.group')
        select.classList.add('select')
        return
      }
      while (select.previousElementSibling !== null) {
        if (select.previousElementSibling.classList.contains('group')) {
          break
        }
        select = select.previousElementSibling
      }
      if (select.previousElementSibling !== null) {
        document.querySelectorAll('.group').forEach(elem => {
          elem.classList.remove('select')
        })
        select.previousElementSibling.classList.add('select')
        let i = select.previousElementSibling.querySelector('input')
        if (i !== null) {
          i.focus()
        }
      }
    },
    onDown () {
      if (this.ignoreControls) return
      let select = document.querySelector('.group.select')
      if (select === null) {
        select = document.querySelector('.group')
        select.classList.add('select')
        return
      }
      while (select.nextElementSibling !== null) {
        if (select.nextElementSibling.classList.contains('group')) {
          break
        }
        select = select.nextElementSibling
      }
      if (select.nextElementSibling !== null) {
        document.querySelectorAll('.group').forEach(elem => {
          elem.classList.remove('select')
        })
        select.nextElementSibling.classList.add('select')
        let i = select.nextElementSibling.querySelector('input')
        if (i !== null) {
          i.focus()
        }
      }
    },
    onEnter () {
      if (this.ignoreControls) return
      let select = document.querySelector('.group.select')
      if (select === null) return
      if (select.dataset !== null) {
        if (select.dataset.type === 'text') {
          const $input = select.querySelector('input')
          Modal.CreateTextModal({
            limit: parseInt(select.dataset.maxlength) || 64,
            text: select.dataset.defaultValue || '',
            title: select.dataset.title || ''
          })
          .then(resp => {
            if (resp !== undefined && resp.text !== undefined) {
              $input.value = resp.text
              $input.dispatchEvent(new window.Event('change'))
            }
          })
          .catch(e => { this.ignoreControls = false })
        }
        if (select.dataset.type === 'button') {
          select.click()
        }
      }
    },
    onBack () {
      if (this.state !== this.STATES.MENU) {
        this.state = this.STATES.MENU
      } else {
        this.$bus.$emit('twitterHome')
      }
    },
    setLocalAccount ($event, key) {
      this.localAccount[key] = $event.target.value
    },
    async onPressChangeAvartar () {
      this.ignoreControls = true
      Modal.CreateModal({ scelte: [
        { id: 1, title: this.LangString('APP_TWITTER_LINK_PICTURE'), icons: 'fa-link' },
        { id: 2, title: this.LangString('APP_TWITTER_TAKE_PICTURE'), icons: 'fa-camera' }
      ] })
      .then(async response => {
        switch(response.id) {
          case 1:
            Modal.CreateTextModal({
              text: this.twitterAvatarUrl || 'https://i.imgur.com/',
              title: this.LangString('TYPE_LINK')
            })
            .then(resp => {
              this.twitterSetAvatar({ avatarUrl: resp.text })
              this.ignoreControls = false
            })
            .catch(e => { this.ignoreControls = false })
            break
          case 2:
            this.$phoneAPI.takePhoto()
            .then(pic => {
              if (this.localAccount.avatarUrl === null) {
                this.localAccount.avatarUrl = pic
                this.twitterAvatarUrl = pic
              }
              this.twitterSetAvatar({ avatarUrl: pic })
              this.ignoreControls = false
            })
            .catch(e => { this.ignoreControls = false })
            break
        }
      })
      .catch(e => { this.ignoreControls = false })
    },
    login () {
      this.twitterLogin({ username: this.localAccount.username, password: this.localAccount.password })
      this.state = STATES.MENU
    },
    createAccount () {
      if (this.validAccount === true) {
        this.twitterCreateNewAccount(this.localAccount)
        this.localAccount = {
          username: '',
          password: '',
          passwordConfirm: '',
          avatarUrl: null
        }
        this.state = this.STATES.MENU
      }
    },
    cancel () {
      this.state = STATES.MENU
    },
    setNotification (value) {
      this.setTwitterNotification(value)
    },
    setNotificationSound (value) {
      this.setTwitterNotificationSound(value)
    },
    async changePassword (value) {
      try {
        Modal.CreateTextModal({
          limit: 40,
          title: this.LangString('APP_TWITTER_TYPE_PASSWORD_TITLE_1'),
          color: 'rgb(55, 161, 242)'
        })
        .then(pass1 => {
          if (pass1.text === '' || pass1.text === null || pass1.text === undefined) return
          Modal.CreateTextModal({
            limit: 40,
            title: this.LangString('APP_TWITTER_TYPE_PASSWORD_TITLE_2'),
            color: 'rgb(55, 161, 242)'
          })
          .then(pass2 => {
            if (pass2.text === '' || pass2.text === null || pass2.text === undefined) return
            if (pass2.text !== pass1.text) {
              this.$notify({
                title: this.LangString('APP_TWITTER_NAME'),
                message: this.LangString('APP_TWITTER_NOTIF_NEW_PASSWORD_MISS_MATCH'),
                icon: 'twitter',
                backgroundColor: '#e0245e80'
              })
              return
            } else if (pass2.text.length < 6) {
              this.$notify({
                title: this.LangString('APP_TWITTER_NAME'),
                message: this.LangString('APP_TWITTER_NOTIF_NEW_PASSWORD_LENGTH_ERROR'),
                icon: 'twitter',
                backgroundColor: '#e0245e80'
              })
              return
            }
            this.twitterChangePassword(pass2.text)
          })
          .catch(e => { this.ignoreControls = false })
        })
        .catch(e => { this.ignoreControls = false })
      } catch (e) { }
    },

    changingRoute(route) {
      console.log(route)
      this.state = STATES[route]
    },
    updateLocalAccountValue(value, data) {
      this.localAccount[value] = data
    }
  },
  created () {
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)

    this.$bus.$on("twitterChangingRoute", this.changingRoute)
    this.$bus.$on("changeLocalTwitterAccountValue", this.updateLocalAccountValue)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)

    this.$bus.$off("twitterChangingRoute", this.changingRoute)
    this.$bus.$off("changeLocalTwitterAccountValue", this.updateLocalAccountValue)
  }
}
</script>
