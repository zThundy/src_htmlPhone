<template>
  <div style="text-align: center; height: 100%;">
    <div v-if="!igAccount.logged" style="height: 100%;" class="flex">
      <img class="instagram_title" src="/html/static/img/app_instagram/instagramtitle.png">

      <div class="middle">
        <div class="insta-input-text" :class="{ select: currentIndex === 0 }">
          <input class="textbox" :placeholder="LangString('APP_TWITTER_ACCOUNT_USERNAME')" type="text" data-type="username" :value="igAccount.username">
          <i class="fa fa-envelope"></i>
        </div>

        <div class="insta-input-text" :class="{ select: currentIndex === 1 }">
          <input class="textbox" :placeholder="LangString('APP_TWITTER_ACCOUNT_PASSWORD')" type="password" data-type="password" :value="igAccount.password">
          <i class="fa fa-key"></i>
        </div>
      </div>

      <div class="bottom" style="height: 60%; margin-top: 20%;">
        <div :class="{ select: currentIndex === 2 }">
          <input type='button' class="insta-btn insta-btn-blue" data-action="login" :value="LangString('APP_TWITTER_ACCOUNT_LOGIN')"/>
        </div>

        <div :class="{ select: currentIndex === 3 }">
          <input type='button' class="insta-btn insta-btn-blue" data-action="changeRoute" data-args="NEW_ACCOUNT" :value="LangString('APP_TWITTER_ACCOUNT_NEW')" />
        </div>
      </div>
    </div>

    <div v-else class="flex">
      <div class="middle">
        <div :class="{ select: currentIndex === 0 }">
          <img class="insta-avatar" :src="igAccount.avatarUrl">
          <input type="button" data-action="changeAvatar" style="display: none" />
        </div>
      </div>

      <div class="bottom">
        <div :class="{ select: currentIndex === 1 }">
          <input type='button' class="insta-btn insta-btn-blue" :value="LangString('APP_INSTAGRAM_ACCOUNT_CHANGE_PASSWORD')" data-action="changePassword" />
        </div>

        <div :class="{ select: currentIndex === 2 }">
          <input type='button' class="insta-btn insta-btn-blue" data-action="changeRoute" data-args="NOTIFICATIONS" :value="LangString('APP_INSTAGRAM_NOTIFICATION')" />
        </div>

        <div :class="{ select: currentIndex === 3 }">
          <input type='button' class="insta-btn insta-btn-red" data-action="logout" :value="LangString('APP_INSTAGRAM_ACCOUNT_LOGOUT')" />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "vuex"
import Modal from '@/components/Modal/index.js'

export default {
  name: 'instagram_menu',
  components: {},
  data () {
    return {
      currentIndex: 0,
    }
  },
  computed: {
    ...mapGetters([
      "LangString",
      "igAccount"
    ])
  },
  methods: {
    ...mapActions([
      "setInstagramAccount",
      "instagramLogout"
    ]),
    onUp() {
      if (this.currentIndex === -1) return
      this.currentIndex--
    },
    onDown() {
      if (this.currentIndex === 3) return
      this.currentIndex++
    },
    changeRoute(route) { this.$bus.$emit("instagramChangingRoute", route) },
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
          this.$bus.$emit("updateInstagramIgnoreControls", true)
          Modal.CreateTextModal({
            text: this.igAccount[input.dataset.type],
            limit: 20,
            title: input.placeholder,
            color: 'rgb(0, 0, 0)'
          })
          .then(resp => {
            const ar = {}
            ar[input.dataset.type] = resp.text
            this.setInstagramAccount(ar)
            this.$bus.$emit("updateInstagramIgnoreControls", false)
          })
          .catch(e => {
            this.$bus.$emit("updateInstagramIgnoreControls", false)
          })
          break
      }
    },

    logout () {
      this.currentIndex = 0
      this.instagramLogout()
    },
    changePassword () {
      this.$bus.$emit("updateInstagramIgnoreControls", true)
      Modal.CreateTextModal({
        limit: 20,
        title: this.LangString('APP_INSTAGRAM_ACCOUNT_CHANGE_PASSWORD'),
        color: 'rgb(55, 161, 242)',
        text: this.igAccount.password || ""
      })
      .then(pass1 => {
        Modal.CreateTextModal({
          limit: 20,
          title: this.LangString('APP_INSTAGRAM_PASSWORD_CONFIRM_LABEL'),
          color: 'rgb(55, 161, 242)',
          text: this.igAccount.passwordConfirm || ""
        })
        .then(pass2 => {
          if (pass2.text !== pass1.text) {
            this.$notify({
              title: this.LangString('ERROR'),
              message: this.LangString('APP_INSTAGRAM_NOTIF_NEW_PASSWORD_MISS_MATCH'),
              icon: 'instagram',
              backgroundColor: 'rgb(55, 161, 242)',
              appName: this.LangString('APP_INSTAGRAM_NAME')
            })
            this.$bus.$emit("updateInstagramIgnoreControls", false)
            return
          } else if (pass2.text.length < 6) {
            this.$notify({
              title: this.LangString('ERROR'),
              message: this.LangString('APP_INSTAGRAM_NOTIF_NEW_PASSWORD_LENGTH_ERROR'),
              icon: 'instagram',
              backgroundColor: 'rgb(55, 161, 242)',
              appName: this.LangString('APP_INSTAGRAM_NAME')
            })
            this.$bus.$emit("updateInstagramIgnoreControls", false)
            return
          }
          this.$phoneAPI.instagram_changePassword(this.igAccount.username, this.igAccount.password, pass2.text)
          this.$bus.$emit("updateInstagramIgnoreControls", false)
        })
        .catch(e => {
          this.$bus.$emit("updateInstagramIgnoreControls", false)
        })
      })
      .catch(e => {
        this.$bus.$emit("updateInstagramIgnoreControls", false)
      })
    },
    changeAvatar() {
      this.$bus.$emit("updateInstagramIgnoreControls", true)
      Modal.CreateModal({ scelte: [
        { id: 1, title: this.LangString('APP_TWITTER_LINK_PICTURE'), icons: 'fa-link' },
        { id: 2, title: this.LangString('APP_TWITTER_TAKE_PICTURE'), icons: 'fa-camera' }
      ] })
      .then(async response => {
        switch(response.id) {
          case 1:
            Modal.CreateTextModal({
              text: this.igAccount.avatarUrl || 'https://i.imgur.com/',
              title: this.LangString('TYPE_LINK')
            })
            .then(resp => {
              this.setInstagramAccount({ avatarUrl: resp.text })
              this.$phoneAPI.instagram_setAvatar(this.igAccount.username, this.igAccount.password, resp.text)
              this.$bus.$emit("updateInstagramIgnoreControls", false)
            })
            .catch(e => {
              this.$bus.$emit("updateInstagramIgnoreControls", false)
            })
            break
          case 2:
            this.$phoneAPI.takePhoto()
            .then(pic => {
              this.setInstagramAccount({ avatarUrl: pic })
              this.$phoneAPI.instagram_setAvatar(this.igAccount.username, this.igAccount.password, pic)
              this.$bus.$emit("updateInstagramIgnoreControls", false)
            })
            .catch(e => {
              this.$bus.$emit("updateInstagramIgnoreControls", false)
            })
            break
        }
      })
      .catch(e => {
        this.$bus.$emit("updateInstagramIgnoreControls", false)
      })
    },
  },
  created() {
    // login the user on first launch of the app
    if (!this.igAccount.logged) this.$phoneAPI.instagram_login(this.igAccount.username, this.igAccount.password)
    // create control events
    this.$bus.$on("instagramOnUP", this.onUp)
    this.$bus.$on("instagramOnDown", this.onDown)
    this.$bus.$on("instagramOnEnter", this.onEnter)
  },
  beforeDestroy() {
    this.$bus.$off("instagramOnUP", this.onUp)
    this.$bus.$off("instagramOnDown", this.onDown)
    this.$bus.$off("instagramOnEnter", this.onEnter)
  }
}
</script>

<style scoped>
@import url("./style.css");
</style>
