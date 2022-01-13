<template>
  <div>
    <div class="top-container"></div>

    <div class="group inputText" data-type="text" data-maxlength='64' data-defaultValue="" data-title="Inserisci un username">
      <input :placeholder="LangString('APP_TWITTER_NEW_ACCOUNT_USERNAME')" type="text" :value="localAccount.username" @change="setLocalAccount($event, 'username')">
      <i class="fa fa-twitter" aria-hidden="true"></i>
      <span class="highlight"></span>
      <span class="bar"></span>
    </div>

    <div class="group inputText" data-type="text" data-model='password' data-maxlength='30' data-title="Digita una password">
      <input :placeholder="LangString('APP_TWITTER_NEW_ACCOUNT_PASSWORD')" autocomplete="new-password" type="password" :value="localAccount.password" @change="setLocalAccount($event, 'password')">
      <i class="fa fa-key" aria-hidden="true"></i>
      <span class="highlight"></span>
      <span class="bar"></span>
    </div>

    <div class="group inputText" data-type="text" data-model='password' data-maxlength='30' data-title="Ripeti la password">
      <input :placeholder="LangString('APP_TWITTER_NEW_ACCOUNT_PASSWORD_CONFIRM')" autocomplete="new-password" type="password" :value="localAccount.passwordConfirm" @change="setLocalAccount($event, 'passwordConfirm')">
      <i class="fa fa-key" aria-hidden="true"></i>
      <span class="highlight"></span>
      <span class="bar"></span>
    </div>

    <div style="margin-top: 42px; margin-bottom: 42px;" class="group img" data-type="button">
      <img :src="localAccount.avatarUrl">
      <input type='button' class="btn btn-blue2" :value="LangString('APP_TWITTER_NEW_ACCOUNT_AVATAR')" @click.stop="setLocalAccountAvartar($event)"/>
    </div>

    <div style="margin-top: 55%;" class="group" data-type="button" @click.stop="createAccount">
      <input type='button' class="btn btn-blue" :class="validAccount ? 'btn-blue' : 'btn-gray'" :value="LangString('APP_TWIITER_ACCOUNT_CREATE')" @click.stop="createAccount"/>
    </div>
  </div>
</template>

<script>
import { mapGetters } from "vuex"
import Modal from '@/components/Modal'

import "./style.css"

export default {
  data() {
    return {}
  },
  computed: {
    ...mapGetters(['LangString', 'twitterUsername', 'twitterPassword', 'twitterAvatarUrl', 'twitterNotification', 'twitterNotificationSound']),
    setLocalAccountAvartar () {
      this.ignoreControls = true
      Modal.CreateModal({ scelte: [
        { id: 1, title: this.LangString('APP_TWITTER_LINK_PICTURE'), icons: 'fa-link' },
        { id: 2, title: this.LangString('APP_TWITTER_TAKE_PICTURE'), icons: 'fa-camera' }
      ] }).then(async choice => {
        switch(choice.id) {
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
  }
}
</script>