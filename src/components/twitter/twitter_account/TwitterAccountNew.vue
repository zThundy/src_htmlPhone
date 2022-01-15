<template>
  <div class="flex">
    <div class="middle">
      <div class="inputText" :class="{ select: currentIndex === 0 }">
        <input :placeholder="LangString('APP_TWITTER_NEW_ACCOUNT_USERNAME')" type="text" data-type="username" :value="account.username">
        <i class="fa fa-twitter"></i>
      </div>

      <div class="inputText" :class="{ select: currentIndex === 1 }">
        <input :placeholder="LangString('APP_TWITTER_NEW_ACCOUNT_PASSWORD')" type="password" data-type="password" :value="account.password">
        <i class="fa fa-key"></i>
      </div>

      <div class="inputText" :class="{ select: currentIndex === 2 }">
        <input :placeholder="LangString('APP_TWITTER_NEW_ACCOUNT_PASSWORD_CONFIRM')" type="password" data-type="passwordConfirm" :value="account.passwordConfirm">
        <i class="fa fa-key"></i>
      </div>

      <div :class="{ select: currentIndex === 3 }">
        <img class="avatar" :src="account.avatarUrl">
        <input type="button" data-action="changeAvatar" style="display: none" />
      </div>
    </div>

    <div class="bottom">
      <div :class="{ select: currentIndex === 4 }">
        <input type='button' data-action="createAccount" class="btn" :class="validAccount ? 'btn-blue' : 'btn-grey'" :value="LangString('APP_TWIITER_ACCOUNT_CREATE')"/>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "vuex"
import Modal from '@/components/Modal'

import "./style.css"

export default {
  data() {
    return {
      currentIndex: 0
    }
  },
  computed: {
    ...mapGetters([
      'LangString',
      'account',
      'twitterNotification',
      'twitterNotificationSound'
    ]),
    validAccount () {
      return this.account.username.length >= 4 && this.account.password.length >= 6 && this.account.password === this.account.passwordConfirm
    },
  },
  methods: {
    ...mapActions([
      "setAccount",
      "twitterLogout",
    ]),
    createAccount() {
      if (!this.validAccount) return
      this.$phoneAPI.twitter_createAccount(this.account.username, this.account.password, this.account.avatarUrl)
      this.changeRoute("MENU")
    },
    changeRoute(route) { this.$bus.$emit("twitterChangingRoute", route) },
    changeAvatar() {
      this.$bus.$emit("updateTwitterIgnoreControls", true)
      Modal.CreateModal({ scelte: [
        { id: 1, title: this.LangString('APP_TWITTER_LINK_PICTURE'), icons: 'fa-link' },
        { id: 2, title: this.LangString('APP_TWITTER_TAKE_PICTURE'), icons: 'fa-camera' }
      ] })
      .then(async response => {
        switch(response.id) {
          case 1:
            Modal.CreateTextModal({
              text: this.account.avatarUrl || 'https://i.imgur.com/',
              title: this.LangString('TYPE_LINK')
            })
            .then(resp => {
              this.setAccount({ avatarUrl: resp.text })
              this.$phoneAPI.twitter_setAvatar(this.account.username, this.account.password, resp.text)
              this.$bus.$emit("updateTwitterIgnoreControls", false)
            })
            .catch(e => {
              this.$bus.$emit("updateTwitterIgnoreControls", false)
            })
            break
          case 2:
            this.$phoneAPI.takePhoto()
            .then(pic => {
              this.setAccount({ avatarUrl: pic })
              this.$phoneAPI.twitter_setAvatar(this.account.username, this.account.password, pic)
              this.$bus.$emit("updateTwitterIgnoreControls", false)
            })
            .catch(e => {
              this.$bus.$emit("updateTwitterIgnoreControls", false)
            })
            break
        }
      })
      .catch(e => {
        this.$bus.$emit("updateTwitterIgnoreControls", false)
      })
    },

    /* FUNZIONI CONTROLLI */
    onUp() {
      if (this.currentIndex === 0) return
      this.currentIndex--
    },
    onDown() {
      this.currentIndex++
    },
    onEnter() {
      const select = document.querySelector('.select')
      if (!select) return
      const input = select.querySelector('input')
      if (!input) return

      switch(input.type) {
        case "button":
          if (input.dataset.action)
            if (this[input.dataset.action])
              this[input.dataset.action](input.dataset.args || null)
          break
        default:
          this.$bus.$emit("updateTwitterIgnoreControls", true)
          Modal.CreateTextModal({
            text: this.account[input.dataset.type],
            limit: 20,
            title: input.placeholder,
            color: 'rgb(38, 111, 167)'
          })
          .then(resp => {
            const ar = {}
            ar[input.dataset.type] = resp.text
            this.setAccount(ar)
            this.$bus.$emit("updateTwitterIgnoreControls", false)
          })
          .catch(e => {
            this.$bus.$emit("updateTwitterIgnoreControls", false)
          })
          break
      }
    },
  },
  created() {
    this.twitterLogout()
    this.$bus.$on("twitterOnUp", this.onUp)
    this.$bus.$on("twitterOnDown", this.onDown)
    this.$bus.$on("twitterOnEnter", this.onEnter)
  },
  beforeDestroy() {
    this.$bus.$off("twitterOnUp", this.onUp)
    this.$bus.$off("twitterOnDown", this.onDown)
    this.$bus.$off("twitterOnEnter", this.onEnter)
  }
}
</script>

<style>
.bottom {
  margin-top: auto;
  margin-bottom: auto;
  position: relative;
  text-align: center;
}

.middle {
  text-align: center;
}

.flex {
  display: flex;
  flex-direction: column;
}
</style>
