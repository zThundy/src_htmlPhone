<template>
  <div style="text-align: center;">
    <div v-if="!isLogin">
      <div class="top-container"></div>

      <div style="margin-top: 50%" class="group inputText" data-type="text" data-maxlength='64' :data-defaultValue="localAccount.username" data-title="Inserisci un username registrato">
        <input :placeholder="LangString('APP_TWITTER_ACCOUNT_USERNAME')" type="text" :value="localAccount.username" @change="setLocalAccount($event, 'username')">
        <i class="fa fa-twitter" aria-hidden="true"></i>
        <span class="highlight"></span>
        <span class="bar"></span>
      </div>

      <div class="group inputText" data-type="text" data-model='password' data-maxlength='30' data-title="Inserisci la password">
        <input :placeholder="LangString('APP_TWITTER_ACCOUNT_PASSWORD')" autocomplete="new-password" type="password" :value="localAccount.password" @change="setLocalAccount($event, 'password')">
        <i class="fa fa-key" aria-hidden="true"></i>
        <span class="highlight"></span>
        <span class="bar"></span>
      </div>

      <div class="group" data-type="button" @click.stop="login">
        <input type='button' class="btn btn-blue2" @click.stop="login" :value="LangString('APP_TWITTER_ACCOUNT_LOGIN')"/>
      </div>

      <div style="bottom: 110px; position: absolute" class="group" data-type="button">
        <input type='button' class="btn btn-blue" @click.stop="changeRoute('NOTIFICATIONS')" :value="LangString('APP_TWITTER_NOTIFICATION')" />
      </div>

      <div style="bottom: 0px: position: absolute" class="group bottom" data-type="button">
        <input type='button' class="btn btn-blue" @click.stop="changeRoute('NEW_ACCOUNT')" :value="LangString('APP_TWITTER_ACCOUNT_NEW')" />
      </div>
    </div>

    <div v-else>
      <img :src="twitterAvatarUrl" style="margin-top: 20px; height: 128px; width: 128px; overflow: auto; border-radius: 100px; align-self: center; object-fit: cover;">

      <div class="group" data-type="button">
        <input type='button' class="btn btn-blue" @click.stop="changeRoute('ACCOUNT')" :value="LangString('APP_TWITTER_ACCOUNT_PARAM')" />
      </div>

      <div class="group" data-type="button">
        <input type='button' class="btn btn-blue" @click.stop="changeRoute('NOTIFICATIONS')" :value="LangString('APP_TWITTER_NOTIFICATION')" />
      </div>

      <div class="group bottom" data-type="button">
        <input type='button' class="btn btn-red" @click.stop="logout" :value="LangString('APP_TWITTER_ACCOUNT_LOGOUT')" />
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

import "./style.css"

export default {
  data() {
    return {
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
      "twitterLogout",
    ]),
    logout () {
      this.twitterLogout()
    },
    changeRoute(route) {
      this.$bus.$emit("twitterChangingRoute", route)
    }
  }
}

</script>