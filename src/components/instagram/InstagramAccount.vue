<template>
  <!--314px, 579px-->
  <div style="width: 100%; height: 600px;" class='content inputText'>

    <template v-if="state === STATI.MENU">
      <template v-if="!isLogin">
        <div class="insta-group" data-type="button" @click.stop="state = STATI.LOGIN">
          <input type='button' class="insta-btn insta-btn-cyan" @click.stop="state = STATI.LOGIN" :value="LangString('APP_INSTAGRAM_ACCOUNT_LOGIN')"/>
        </div>

        <div class="insta-group" data-type="button" @click.stop="state = STATI.NOTIFICATION">
          <input type='button' class="insta-btn insta-btn-gray" @click.stop="state = STATI.NOTIFICATION" :value="LangString('APP_INSTAGRAM_NOTIFICATION')" />
        </div>

        <div class="insta-group bottom" data-type="button" @click.stop="state = STATI.NEW_ACCOUNT">
          <input type='button' class="insta-btn insta-btn-border" @click.stop="state = STATI.NEW_ACCOUNT" :value="LangString('APP_INSTAGRAM_ACCOUNT_NEW')" />
        </div>
      </template>

      <template v-if="isLogin">
        <img :src="instagramAvatarUrl" class="insta-loggedInImage">

        <div class="insta-group" data-type="button" @click.stop="state = STATI.ACCOUNT">
          <input type='button' class="insta-btn insta-btn-gray" @click.stop="state = STATI.ACCOUNT" :value="LangString('APP_INSTAGRAM_ACCOUNT_PARAM')" />
        </div>

        <div class="insta-group" data-type="button" @click.stop="state = STATI.NOTIFICATION">
          <input type='button' class="insta-btn insta-btn-gray" @click.stop="state = STATI.NOTIFICATION" :value="LangString('APP_INSTAGRAM_NOTIFICATION')" />
        </div>

        <div class="insta-group bottom" data-type="button" @click.stop="logout">
          <input type='button' class="insta-btn insta-btn-red" @click.stop="logout" :value="LangString('APP_INSTAGRAM_ACCOUNT_LOGOUT')" />
        </div>
      </template>
    </template>

    <!-- PAGINA LOGIN CON USERNAME E PASSWORD -->
    <template v-else-if="state === STATI.LOGIN">
      <img class="instagram_title" src="/html/static/img/app_instagram/instagramtitle.png">

      <div class="insta-group inputText" data-type="text" :data-defaultValue="accountLocale.username" data-title="Inserisci un nickname registrato">
        <input class="insta-loginBoxes" :placeholder="LangString('APP_INSTAGRAM_USERNAME_LABEL')" type="text" :value="accountLocale.username" @change="setLocalAccount($event, 'username')">
        <span class="insta-highlight"><i class="anim fa fa-user fa-lg"></i></span>
      </div>

      <div class="insta-group inputText" data-type="text" data-model='password'  data-title="Inserisci la password">
        <input class="insta-loginBoxes" :placeholder="LangString('APP_INSTAGRAM_PASSWORD_LABEL')" autocomplete="new-password" type="password" :value="accountLocale.password" @change="setLocalAccount($event, 'password')">
        <span class="insta-highlight"><i class="fa fa-lock fa-lg"></i></span>
      </div>

      <div class="insta-group" data-type="button" @click.stop="login">
        <!-- <input type='button' class="insta-btn insta-btn-generic" @click.stop="login" :value="LangString('APP_INSTAGRAM_ACCOUNT_LOGIN')" /> -->
        <input name="login-insta-btn" type='button' class="insta-btn insta-btn-cyan insta-btn-action" @click.stop="login"/>
        <label for="login-insta-btn" class="login-insta-btn-label">Log in</label>
      </div>
    </template>

    <!-- PAGINA CON IMPOSTAZIONI DELLE NOTIFICHE -->
    <template v-else-if="state === STATI.NOTIFICATION">
      <div class="insta-groupCheckBoxTitle">
        <i class="fa fa-cogs" style="padding-top: 5px; padding-left: 5px; margin-right: 10px;"></i>
        <label style="font-weight: 500;">{{ LangString('APP_INSTAGRAM_NOTIFICATION_SOUND') }}</label>
      </div>

      <label class="insta-group insta-checkbox" data-type="button" @click.prevent.stop="setNotification(2)">
        <input type="insta-checkbox" :checked="instagramNotification === 2" @click.prevent.stop="setNotification(2)">
        {{ LangString('APP_TWITTER_NOTIFICATION_ALL') }}
      </label>

      <label class="insta-group insta-checkbox" data-type="button" @click.prevent.stop="setNotification(1)">
        <input type="insta-checkbox" :checked="instagramNotification === 1" @click.prevent.stop="setNotification(1)">
        {{ LangString('APP_TWITTER_NOTIFICATION_MENTION') }}
      </label>

      <label class="insta-group insta-checkbox" data-type="button" @click.prevent.stop="setNotification(0)">
        <input type="insta-checkbox" :checked="instagramNotification === 0" @click.prevent.stop="setNotification(0)">
        {{ LangString('APP_TWITTER_NOTIFICATION_NEVER') }}
      </label>

      <div class="insta-groupCheckBoxTitle">
        <i class="fa fa-bell" style="padding-top: 5px; padding-left: 5px; margin-right: 10px;"></i>
        <label style="font-weight: 500;">{{ LangString('APP_TWITTER_NOTIFICATION_SOUND') }}</label>
      </div>

      <label class="insta-group insta-checkbox" data-type="button" @click.prevent.stop="setNotificationSound(true)">
        <input type="insta-checkbox" :checked="instagramNotificationSound" @click.prevent.stop="setNotificationSound(true)">
        {{ LangString('APP_TWITTER_NOTIFICATION_SOUND_YES') }}
      </label>

      <label class="insta-group insta-checkbox" data-type="button" @click.prevent.stop="setNotificationSound(false)">
        <input type="insta-checkbox" :checked="!instagramNotificationSound" @click.prevent.stop="setNotificationSound(false)">
        {{ LangString('APP_TWITTER_NOTIFICATION_SOUND_NO') }}
      </label>
    </template>

    <template v-else-if="state === STATI.ACCOUNT">
      <img :src="instagramAvatarUrl" class="insta-loggedInImage">

      <div style="margin-top: 50px;" class="insta-group" data-type="button" @click.stop="onPressChangeAvartar">
        <input type='button' class="insta-btn insta-btn-cyan" @click.stop="onPressChangeAvartar" :value="LangString('APP_INSTAGRAM_ACCOUNT_AVATAR')"/>
      </div>
      
      <div class="insta-group bottom" data-type="button" @click.stop="changePassword">
        <input type='button' class="insta-btn insta-btn-border" @click.stop="changePassword" :value="LangString('APP_INSTAGRAM_ACCOUNT_CHANGE_PASSWORD')" />
      </div>
    </template>

    <template v-else-if="state === STATI.NEW_ACCOUNT">
      <img class="instagram_title" src="/html/static/img/app_instagram/instagramtitle.png">

      <div class="insta-group inputText" data-type="text" :data-defaultValue="accountLocale.username" data-title="Scegli un nickname unico">
        <input class="insta-loginBoxes" :placeholder="LangString('APP_INSTAGRAM_USERNAME_LABEL')" type="text" :value="accountLocale.username" @change="setLocalAccount($event, 'username')">
        <span class="insta-highlight"><i class="anim fa fa-user fa-lg"></i></span>
      </div>

      <div class="insta-group inputText" data-type="text" data-model='password' data-title="Digita una password">
        <input class="insta-loginBoxes" :placeholder="LangString('APP_INSTAGRAM_PASSWORD_LABEL')" autocomplete="new-password" type="password" :value="accountLocale.password" @change="setLocalAccount($event, 'password')">
        <span class="insta-highlight"><i class="fa fa-lock fa-lg"></i></span>
      </div>

      <div class="insta-group inputText" data-type="text" data-model='password' data-title="Ripeti la password">
        <input class="insta-loginBoxes" :placeholder="LangString('APP_INSTAGRAM_PASSWORD_CONFIRM_LABEL')" autocomplete="new-password" type="password" :value="accountLocale.passwordConfirm" @change="setLocalAccount($event, 'passwordConfirm')">
        <span class="insta-highlight"><i class="fa fa-lock fa-lg"></i></span>
      </div>

      <div style="overflow-x: hidden; overflow-y: hidden;" class="insta-group" data-type="button" @click.stop="createAccount">
        <!-- <input type='button' class="insta-btn insta-btn-generic" @click.stop="login" :value="LangString('APP_INSTAGRAM_ACCOUNT_LOGIN')" /> -->
        <input name="login-insta-btn" type='button' class="insta-btn insta-btn-cyan insta-btn-action" @click.stop="createAccount"/>
        <label for="login-insta-btn" class="login-insta-btn-label">Registrati</label>
      </div>
    </template>

  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import Modal from '@/components/Modal'

const STATI = Object.freeze({
  MENU: 0,
  NEW_ACCOUNT: 1,
  LOGIN: 2,
  ACCOUNT: 3,
  NOTIFICATION: 4
})

export default {
  components: {
  },
  data () {
    return {
      STATI,
      state: STATI.MENU,
      accountLocale: {
        username: '',
        password: '',
        passwordConfirm: '',
        avatarUrl: '/html/static/img/app_instagram/default_profile.png'
      },
      notification: 0,
      notificationSound: false,
      ignoreControls: false
    }
  },
  computed: {
    ...mapGetters(['LangString', 'instagramUsername', 'instagramPassword', 'instagramAvatarUrl', 'instagramNotification', 'instagramNotificationSound']),
    isLogin () {
      return this.instagramUsername !== undefined && this.instagramUsername !== ''
    },
    validAccount () {
      return this.accountLocale.username.length >= 4 && this.accountLocale.password.length >= 6 && this.accountLocale.password === this.accountLocale.passwordConfirm
    }
  },
  methods: {
    ...mapActions(['instagramChangePassword', 'instagramLogout', 'instagramSetAvatar', 'setInstagramNotification', 'setInstagramNotificationSound']),
    onUp: function () {
      if (this.ignoreControls) return
      let select = document.querySelector('.insta-group.insta-select')
      if (select === null) {
        select = document.querySelector('.insta-group')
        select.classList.add('insta-select')
        return
      }
      while (select.previousElementSibling !== null) {
        if (select.previousElementSibling.classList.contains('insta-group')) {
          break
        }
        select = select.previousElementSibling
      }
      if (select.previousElementSibling !== null) {
        document.querySelectorAll('.insta-group').forEach(elem => {
          elem.classList.remove('insta-select')
        })
        select.previousElementSibling.classList.add('insta-select')
        let i = select.previousElementSibling.querySelector('input')
        if (i !== null) {
          i.focus()
        }
      }
    },
    onDown: function () {
      if (this.ignoreControls) return
      let select = document.querySelector('.insta-group.insta-select')
      if (select === null) {
        select = document.querySelector('.insta-group')
        select.classList.add('insta-select')
        return
      }
      while (select.nextElementSibling !== null) {
        if (select.nextElementSibling.classList.contains('insta-group')) {
          break
        }
        select = insta-select.nextElementSibling
      }
      if (select.nextElementSibling !== null) {
        document.querySelectorAll('.insta-group').forEach(elem => {
          elem.classList.remove('insta-select')
        })
        select.nextElementSibling.classList.add('insta-select')
        let i = select.nextElementSibling.querySelector('input')
        if (i !== null) {
          i.focus()
        }
      }
    },
    onEnter () {
      if (this.ignoreControls) return
      let select = document.querySelector('.insta-group.insta-select')
      if (select === null) return
      if (select.dataset !== null) {
        if (select.dataset.type === 'text') {
          const $input = insta-select.querySelector('input')
          Modal.CreateTextModal({
            limit: parseInt(select.dataset.maxlength) || 64,
            text: select.dataset.defaultValue || '',
            title: select.dataset.title || '',
            color: 'rgba(0, 0, 0, .01)'
          })
          .then(resp => {
            $input.value = resp.text
            $input.dispatchEvent(new window.Event('change'))
            this.ignoreControls = false
          })
          .catch(e => { this.ignoreControls = false })
        }
        if (select.dataset.type === 'button') {
          select.click()
        }
      }
    },
    onBack () {
      if (this.state !== this.STATI.MENU) {
        this.state = this.STATI.MENU
      } else {
        this.$bus.$emit('instagramHome')
      }
    },
    setLocalAccount ($event, key) {
      this.accountLocale[key] = $event.target.value
    },
    onPressChangeAvartar () {
      try {
        this.ignoreControls = true
        Modal.CreateModal({ scelte: [
          { id: 1, title: this.LangString('APP_TWITTER_LINK_PICTURE'), icons: 'fa-link' },
          { id: 2, title: this.LangString('APP_TWITTER_TAKE_PICTURE'), icons: 'fa-camera' }
        ] })
        .then(async resp => {
          switch(resp.id) {
            case 1:
              Modal.CreateTextModal({
                text: this.instagramAvatarUrl || 'https://i.imgur.com/',
                color: 'rgba(0, 0, 0, .01)',
                title: this.LangString('TYPE_LINK')
              })
              .then(response => {
                this.instagramSetAvatar({ avatarUrl: response.text })
                this.ignoreControls = false
              })
              .catch(e => { this.ignoreControls = false })
              break
            case 2:
              this.$phoneAPI.takePhoto()
              .then(pic => {
                if (this.accountLocale.avatarUrl === null) {
                  this.accountLocale.avatarUrl = pic
                  this.instagramAvatarUrl = pic
                }
                this.instagramSetAvatar({ avatarUrl: pic })
                this.ignoreControls = false
              })
              .catch(e => { this.ignoreControls = false })
              break
          }
        })
        .catch(e => { this.ignoreControls = false })
      } catch (e) {}
    },
    login () {
      this.$phoneAPI.instagram_login(this.accountLocale.username, this.accountLocale.password)
      this.state = STATI.MENU
    },
    logout () {
      this.instagramLogout()
    },
    createAccount () {
      if (this.validAccount === true) {
        this.$phoneAPI.instagram_createAccount(this.accountLocale.username, this.accountLocale.password, this.accountLocale.avatarUrl)
        this.accountLocale = {
          username: '',
          password: '',
          passwordConfirm: '',
          avatarUrl: null
        }
        this.state = this.STATI.MENU
      }
    },
    cancel () {
      this.state = STATI.MENU
    },
    setNotification (value) {
      this.setInstagramNotification(value)
    },
    setNotificationSound (value) {
      this.setInstagramNotificationSound(value)
    },
    changePassword () {
      if (this.ignoreControls) return
      this.ignoreControls = true
      // SEZIONE MODAL ASYNC //
      Modal.CreateTextModal({
        limit: 40,
        title: this.LangString('APP_INSTAGRAM_TYPE_PASSWORD_TITLE_1'),
        color: 'rgba(0, 0, 0, .01)'
      })
      .then(pass1 => {
        if (pass1.text === '' || pass1.text === null || pass1.text === undefined) return
        Modal.CreateTextModal({
          limit: 40,
          title: this.LangString('APP_INSTAGRAM_TYPE_PASSWORD_TITLE_2'),
          color: 'rgba(0, 0, 0, .01)'
        })
        .then(pass2 => {
          if (pass2.text === '' || pass2.text === null || pass2.text === undefined) return
          if (pass1.text !== pass2.text) {
            this.$notify({
              title: this.LangString('APP_INSTAGRAM_NAME'),
              message: this.LangString('APP_INSTAGRAM_NOTIF_NEW_PASSWORD_MISS_MATCH'),
              icon: 'instagram',
              backgroundColor: '#66000080'
            })
            setTimeout(() => { this.ignoreControls = false }, 200)
          } else if (pass2.text.length < 6) {
            this.$notify({
              title: this.LangString('APP_INSTAGRAM_NAME'),
              message: this.LangString('APP_INSTAGRAM_NOTIF_NEW_PASSWORD_LENGTH_ERROR'),
              icon: 'instagram',
              backgroundColor: '#66000080'
            })
            setTimeout(() => { this.ignoreControls = false }, 200)
          } else {
            setTimeout(() => { this.ignoreControls = false }, 200)
            this.instagramChangePassword(pass2.text)
          }
        })
        .catch(e => { this.ignoreControls = false })
      })
      .catch(e => { this.ignoreControls = false })
    }
  },
  created () {
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.background_color {
  position: relative;
  top: 0;
  background: -moz-linear-gradient(45deg, #f09433 0%, #e6683c 25%, #dc2743 50%, #cc2366 75%, #bc1888 100%); 
  background: -webkit-linear-gradient(45deg, #f09433 0%,#e6683c 25%,#dc2743 50%,#cc2366 75%,#bc1888 100%); 
  background: linear-gradient(45deg, #f09433 0%,#e6683c 25%,#dc2743 50%,#cc2366 75%,#bc1888 100%); 
  filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#f09433', endColorstr='#bc1888',GradientType=1 );
}

.content {
  padding-top: 20px;
  margin-top: 0px;
  height: calc(100% - 48px);
  display: flex;
  flex-direction: column;
}

/* #################################### */
/* RAGGRUPPAMENTO ELEMENTI NEI TEMPLATE */
/* #################################### */

.insta-group {
  position: relative;
  margin-top: 24px;
  height: 60px;
}

.insta-group.inputText {
  position: relative;
  padding-left: 25px;
}

.insta-group.bottom {
  margin-top: auto;
}

.insta-group.img {
  display: flex;
  flex-direction: row;
  align-items: center;
}

.insta-group.img img{
  display: flex;
  flex-direction: row;
  overflow: auto;
  flex-grow: 0;
  flex: 0 0 128px;
  margin-right: 24px;
  border-radius: 100px;
  object-fit: cover;
}

/* ######################### */
/* PAGINA LOGIN DI INSTAGRAM */
/* ######################### */

.instagram_title {
  width: 250px;
  margin-left: auto;
  margin-right: auto;
}

.insta-loginBoxes {
  opacity: 0.6;
  border-radius: 5px;
  background-color: rgb(228, 228, 228);
  border: 1px solid rgba(0,0,0,0.3);
  padding-left: 50px;
  font-size: 18px;
}

.insta-select .insta-loginBoxes {
  border: 1px solid rgb(0, 149, 248);
  box-shadow: 0px 0px 3px 1px rgb(0, 149, 248);
}

input {
  font-size: 24px;
  display: flexbox;
  padding-left: 2px;
  width: 91%;
  height: 50px;
  border: none;
  border-bottom: 1px solid #757575;
}

input:focus { 
  outline: none; 
  opacity: 0.9;
}

.insta-LoginText {
  top: 18px;
  bottom: 0px;
  justify-content: center;
  color: black;
  font-size: 20px;
}

.insta-group.insta-select .insta-LoginText {
  color: #fff;
  background-color: #2196f3;
}

@keyframes buttonMove {
	from { padding-left: 130px; }
  to { padding-left: 50px; }
}

@keyframes buttonMoveOff {
	from { padding-left: 50px; }
  to { padding-left: 130px; }
}

/* ######################### */
/* ACCOUNT LOGGATO INSTAGRAM */
/* ######################### */

.insta-loggedInImage {
  height: 128px; 
  width: 128px; 
  overflow: auto; 
  border-radius: 100px; 
  align-self: center; 
  object-fit: cover;
  border-style: solid;
  border-width: 1px;
}

.insta-group .insta-btn.insta-btn-gray{
  position: absolute;
  color: #222;
  background-color: rgba(163, 163, 163, 0.4);
  border-radius: 10px;
}

.insta-group .insta-btn.insta-btn-cyan{
  position: absolute;
  color: #fff;
  background-color: #2196f3;
  border-radius: 10px;
}

.insta-btn-action {
  border-radius: 7px !important;
}

.insta-group.insta-select .insta-btn.insta-btn-gray, .insta-group.insta-select .insta-btn.insta-btn-cyan, .insta-group.insta-select .insta-btn.insta-btn-border {
  background-color: rgba(0, 0, 0, 0.9);
  color: white;
}

.insta-group.insta-select .insta-btn-action {
  background-color: rgba(0, 0, 0, 0.0) !important;
  border: 1px solid #2196f3;
}

.insta-group .insta-btn.insta-btn-red {
  bottom: 50px;
  position: absolute;
  font-weight: bold;
  border-radius: 10px;
  background-color: rgba(255, 0, 0, 0.9);
  color: white;
  width: 193px;
  margin: 0 auto;
  margin-bottom: 50px;
  animation: redButtonOff 0.8s ease;
  animation-fill-mode: forwards; 
}

.insta-group.insta-select .insta-btn.insta-btn-red {
  background-color: rgba(255, 0, 0, 0.9);
  color: white;
  border: none;
  animation: redButton 0.8s ease;
  animation-fill-mode: forwards; 
}

.insta-group .insta-btn.insta-btn-green {
  left: 55px;
  bottom: 50px;
  position: absolute;
  font-weight: bold;
  border-radius: 10px;
  background-color: rgba(0, 175, 0, 0.8);
  color: white;
  width: 193px;
  margin: 0 auto;
  margin-bottom: 50px;
  animation: redButtonOff 0.8s ease;
  animation-fill-mode: forwards; 
}

.insta-group.insta-select .insta-btn.insta-btn-green {
  background-color: rgba(0, 175, 0, 0.8);
  color: white;
  border: none;
  animation: redButton 0.8s ease;
  animation-fill-mode: forwards; 
}

.insta-group .insta-btn.insta-btn-border {
  bottom: 0;
  border-top: 2px solid rgb(153, 153, 153);
  position: absolute;
  background-color: rgba(0, 0, 0, 0.0);
  color: black;
  width: 100%;
  box-shadow: 0px 0px 11px 1px rgba(0,0,0,0.35);
}

@keyframes redButton {
	from { opacity: 0.0; }
  to { opacity: 1.0; }
}

@keyframes redButtonOff {
	from { opacity: 1.0; }
  to { opacity: 0.0; }
}

/* ################## */
/* CHECKBOX NOTIFICHE */
/* ################## */

.insta-groupCheckBoxTitle {
  font-weight: 700;
  margin-top: 12px;
  margin-left: 10px;
}

.insta-group.inputText label {
  color: rgb(0, 0, 0);
  font-size: 18px;
  font-weight: normal;
  position: absolute;
  pointer-events: none;
  left: 5px;
  top: 10px;
  transition: 0.2s ease all;
  -moz-transition: 0.2s ease all;
  -webkit-transition: 0.2s ease all;
}

.insta-checkbox {
  display: flex;
  height: 50px;
  line-height: 45px;
  align-items: center;
  color: #000000;
  font-weight: bold;
  border-radius: 6px;
  padding-left: 12px;
  margin-top: 5px;

  animation: checkboxOpacityOn 0.5s ease;
  animation-fill-mode: forwards;
}

.insta-checkbox input {
  width: 24px;
  height: 0px;
  opacity: 1;
  margin-left: 20px;
}

.insta-checkbox.insta-select {
  border: 1px solid rgba(0,0,0,0.7);
  background-color: rgba(0,0,0,0.7);
  color: white;

  animation: checkboxOpacityOff 0.5s ease;
  animation-fill-mode: forwards;
}

@keyframes checkboxOpacityOff {
	from { opacity: 0.2; }
  to 	{ opacity: 1.0; }
}

@keyframes checkboxOpacityOn {
	from { opacity: 1.0; }
  to 	{ opacity: 0.2; }
}

/* QUANDO PREMI E IL PALLINO CAMBIA COLORE */ 

.insta-checkbox input::after {
  box-sizing: border-box;
  content: '';
  opacity: 1;
  position: absolute;
  left: 25px;
  margin-top: -10px;

  animation: pallinoRotazioneOff 0.5s ease;
  animation-fill-mode: forwards;
}

.insta-checkbox input:checked::after {
  animation: pallinoRotazione 0.5s ease;
  animation-fill-mode: forwards;
}

@keyframes pallinoRotazione {
  from {
    opacity: 0.6;
    transform: rotate(0deg);
  }
  to {
    opacity: 1.0;
    transform: rotate(360deg);
  }
}

@keyframes pallinoRotazioneOff {
  from {
    opacity: 1.0;
    transform: rotate(360deg);
  }
  to {
    opacity: 0.6;
    transform: rotate(0deg);
  }
}

/* active state */
.insta-group.inputText input:focus ~ label, .insta-group.inputText input:valid ~ label 		{
  top: -24px;
  font-size: 18px;
  color: rgba(0,0,0,0.7);
}

/* HIGHLIGHTER ================================== */
.insta-highlight {
  position: absolute;
  height: 70%;
  width: 20%;
  border-radius: 10px;
  top: 20%;
  left: 40px;
  pointer-events: none;
  opacity: 0.5;
}

.insta-group .insta-btn {
  width: 85%;
  padding: 0px 0px;
  height: 50px;
  color: rgb(156, 156, 156);
  border: 0 none;
  font-size: 22px;
  font-weight: 200;
  line-height: 34px;
  color: #202129;
  background-color: rgb(156, 156, 156);
  margin-left: auto;
  margin-right: auto;
  left: 0;
  right: 0;
}

.insta-group .insta-btn.insta-btn-generic {
  width: 260px;
  margin-left: 25px;
  border: 2px solid #999999;
  color: #acacac;
  background-color: rgba(255, 255, 255, 0);
  font-weight: 500;
  opacity: 0.4;
  border-radius: 5px;
  font-weight: 300;
  font-size: 19px;
}

.insta-group.insta-select .insta-btn.insta-btn-generic {
  background-color: rgba(0, 0, 0, 0.8);
  color: white;
  opacity: 0.8;
  border: none;
}

.login-insta-btn-label {
  position: absolute;
  width: max-content;
  margin-left: auto;
  margin-right: auto;
  left: 0;
  right: 0;
  top: 12px;
  color: white;
}

.insta-select .login-insta-btn-label {
  color: #000000 !important;
}
</style>
