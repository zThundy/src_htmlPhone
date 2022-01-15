<template>
  <div style="text-align: center; height: 100%;">
    <div v-if="!account.logged" style="height: 100%;" class="flex">
      <i class="fa fa-twitter twt-icon"></i>

      <div class="middle">
        <div class="inputText" :class="{ select: currentIndex === 0 }">
          <input :placeholder="LangString('APP_TWITTER_ACCOUNT_USERNAME')" type="text" data-type="username" :value="account.username">
          <i class="fa fa-envelope"></i>
        </div>

        <div class="inputText" :class="{ select: currentIndex === 1 }">
          <input :placeholder="LangString('APP_TWITTER_ACCOUNT_PASSWORD')" type="password" data-type="password" :value="account.password">
          <i class="fa fa-key"></i>
        </div>
      </div>

      <div class="bottom">
        <div :class="{ select: currentIndex === 2 }">
          <input type='button' class="btn btn-blue2" data-action="login" :value="LangString('APP_TWITTER_ACCOUNT_LOGIN')"/>
        </div>

        <div :class="{ select: currentIndex === 3 }">
          <input type='button' class="btn btn-blue" data-action="changeRoute" data-args="NEW_ACCOUNT" :value="LangString('APP_TWITTER_ACCOUNT_NEW')" />
        </div>
      </div>
    </div>

    <div v-else class="flex">
      <div class="middle">
        <div :class="{ select: currentIndex === 0 }">
          <img class="avatar" :src="account.avatarUrl">
          <input type="button" data-action="changeAvatar" style="display: none" />
        </div>
      </div>

      <div class="bottom">
        <div :class="{ select: currentIndex === 1 }">
          <input type='button' class="btn btn-blue" :value="LangString('APP_TWITTER_ACCOUNT_CHANGE_PASSWORD')" data-action="changePassword" />
        </div>

        <div :class="{ select: currentIndex === 2 }">
          <input type='button' class="btn btn-blue" data-action="changeRoute" data-args="NOTIFICATIONS" :value="LangString('APP_TWITTER_NOTIFICATION')" />
        </div>

        <div :class="{ select: currentIndex === 3 }">
          <input type='button' class="btn btn-red" data-action="logout" :value="LangString('APP_TWITTER_ACCOUNT_LOGOUT')" />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
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
      "account"
    ]),
  },
  methods: {
    ...mapActions([
      "twitterLogout",
      "setAccount"
    ]),
    login () {
      this.currentIndex = 0
      this.$phoneAPI.twitter_login(this.account.username, this.account.password)
    },
    logout () {
      this.currentIndex = 0
      this.twitterLogout()
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

    changePassword () {
      this.$bus.$emit("updateTwitterIgnoreControls", true)
      Modal.CreateTextModal({
        limit: 20,
        title: this.LangString('APP_TWITTER_TYPE_PASSWORD_TITLE_1'),
        color: 'rgb(55, 161, 242)',
        text: this.account.password || ""
      })
      .then(pass1 => {
        Modal.CreateTextModal({
          limit: 20,
          title: this.LangString('APP_TWITTER_TYPE_PASSWORD_TITLE_2'),
          color: 'rgb(55, 161, 242)',
          text: this.account.passwordConfirm || ""
        })
        .then(pass2 => {
          if (pass2.text !== pass1.text) {
            this.$notify({
              title: this.LangString('ERROR'),
              message: this.LangString('APP_TWITTER_NOTIF_NEW_PASSWORD_MISS_MATCH'),
              icon: 'twitter',
              backgroundColor: 'rgb(55, 161, 242)',
              appName: this.LangString('APP_TWITTER_NAME')
            })
            this.$bus.$emit("updateTwitterIgnoreControls", false)
            return
          } else if (pass2.text.length < 6) {
            this.$notify({
              title: this.LangString('ERROR'),
              message: this.LangString('APP_TWITTER_NOTIF_NEW_PASSWORD_LENGTH_ERROR'),
              icon: 'twitter',
              backgroundColor: 'rgb(55, 161, 242)',
              appName: this.LangString('APP_TWITTER_NAME')
            })
            this.$bus.$emit("updateTwitterIgnoreControls", false)
            return
          }
          this.$phoneAPI.twitter_changePassword(this.account.username, this.account.password, pass2.text)
          this.$bus.$emit("updateTwitterIgnoreControls", false)
        })
        .catch(e => {
          this.$bus.$emit("updateTwitterIgnoreControls", false)
        })
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
    // login the user on first launch of the app
    if (!this.account.logged) this.$phoneAPI.twitter_login(this.account.username, this.account.password)
    // create control events
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

<style scoped>
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