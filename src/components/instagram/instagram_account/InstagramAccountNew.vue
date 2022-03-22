<template>
  <div class="flex">
    <div class="middle">
      <div class="insta-input-text" :class="{ select: currentIndex === 0 }">
        <input :placeholder="LangString('APP_INSTAGRAM_USERNAME_LABEL')" type="text" data-type="username" :value="igAccount.username">
        <i class="fa fa-instagram"></i>
      </div>

      <div class="insta-input-text" :class="{ select: currentIndex === 1 }">
        <input :placeholder="LangString('APP_INSTAGRAM_TYPE_PASSWORD_TITLE_1')" type="password" data-type="password" :value="igAccount.password">
        <i class="fa fa-key"></i>
      </div>

      <div class="insta-input-text" :class="{ select: currentIndex === 2 }">
        <input :placeholder="LangString('APP_INSTAGRAM_TYPE_PASSWORD_TITLE_2')" type="password" data-type="passwordConfirm" :value="igAccount.passwordConfirm">
        <i class="fa fa-key"></i>
      </div>

      <div :class="{ select: currentIndex === 3 }">
        <img class="insta-avatar" :src="igAccount.avatarUrl">
        <input type="button" data-action="changeAvatar" style="display: none" />
      </div>
    </div>

    <div class="bottom">
      <div :class="{ select: currentIndex === 4 }">
        <input type='button' data-action="createAccount" class="insta-btn" :class="validAccount ? 'insta-btn-blue' : 'insta-btn-grey'" :value="LangString('APP_INSTAGRAM_ACCOUNT_NEW')"/>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "vuex"
import Modal from '@/components/Modal'

export default {
  data() {
    return {
      currentIndex: 0
    }
  },
  computed: {
    ...mapGetters([
      'LangString',
      'igAccount',
      'instagramNotification',
      'instagramNotificationSound'
    ]),
    validAccount () {
      return this.igAccount.username.length >= 4 && this.igAccount.password.length >= 6 && this.igAccount.password === this.igAccount.passwordConfirm
    },
  },
  methods: {
    ...mapActions([
      "setInstagramAccount",
      "instagramLogout",
    ]),
    createAccount() {
      if (!this.validAccount) return
      this.$phoneAPI.instagram_createAccount(this.igAccount.username, this.igAccount.password, this.igAccount.avatarUrl)
      this.changeRoute("MENU")
    },
    changeRoute(route) { this.$bus.$emit("instagramChangingRoute", route) },
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
          this.$bus.$emit("updateInstagramIgnoreControls", true)
          Modal.CreateTextModal({
            text: this.igAccount[input.dataset.type],
            limit: 20,
            title: input.placeholder,
            color: 'rgb(38, 111, 167)'
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
  },
  created() {
    this.instagramLogout()
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

<style>
@import url("./style.css");

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
