<template>
  <div style="width: 330px; height: 100%;" class='content'>
    
    <template v-if="state === STATES.MENU">
      <template v-if="!isLogin">
        <div class="top-container">
        </div>
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

        <div  style="bottom: 110px; position: absolute" class="group" data-type="button" @click.stop="state = STATES.NOTIFICATION">
          <input type='button' class="btn btn-blue" @click.stop="state = STATES.NOTIFICATION" :value="LangString('APP_TWITTER_NOTIFICATION')" />
        </div>
       
        <div style="bottom: 0px: position: absolute" class="group bottom" data-type="button" @click.stop="state = STATES.NEW_ACCOUNT">
          <input type='button' class="btn btn-blue" @click.stop="state = STATES.NEW_ACCOUNT" :value="LangString('APP_TWITTER_ACCOUNT_NEW')" />
        </div>   
      </template>

      <template v-if="isLogin">
        <img :src="twitterAvatarUrl" style="margin-top: 20px; height: 128px; width: 128px; overflow: auto; border-radius: 100px; align-self: center; object-fit: cover;">

        <div class="group" data-type="button" @click.stop="state = STATES.ACCOUNT">
          <input type='button' class="btn btn-blue" @click.stop="state = STATES.ACCOUNT" :value="LangString('APP_TWITTER_ACCOUNT_PARAM')" />
        </div>

        <div class="group" data-type="button" @click.stop="state = STATES.NOTIFICATION">
          <input type='button' class="btn btn-blue" @click.stop="state = STATES.NOTIFICATION" :value="LangString('APP_TWITTER_NOTIFICATION')" />
        </div>

        <div class="group bottom" data-type="button" @click.stop="logout">
          <input type='button' class="btn btn-red" @click.stop="logout" :value="LangString('APP_TWITTER_ACCOUNT_LOGOUT')" />
        </div>
      </template>
    </template>

    <template v-else-if="state === STATES.NEW_ACCOUNT">
      <div class="top-container">
      </div>
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

      <div style="margin-top: 42px; margin-bottom: 42px;" class="group img" data-type="button" @click.stop="setLocalAccountAvartar($event)">
        <img :src="localAccount.avatarUrl" @click.stop="setLocalAccountAvartar($event)">
        <input type='button' class="btn btn-blue2" :value="LangString('APP_TWITTER_NEW_ACCOUNT_AVATAR')" @click.stop="setLocalAccountAvartar($event)"/>
      </div>

      <div style="margin-top: 55%;" class="group" data-type="button" @click.stop="createAccount">
        <input type='button' class="btn btn-blue" :class="validAccount ? 'btn-blue' : 'btn-gray'" :value="LangString('APP_TWIITER_ACCOUNT_CREATE')" @click.stop="createAccount"/>
      </div>
    </template>

    <template v-else-if="state === STATES.NOTIFICATION">
      <div class="groupCheckBoxTitle">
        <label>{{ LangString('APP_TWITTER_NOTIFICATION_WHEN') }}</label>
      </div>

      <label class="group checkbox" data-type="button" @click.prevent.stop="setNotification(2)">
        <input type="checkbox" :checked="twitterNotification === 2" @click.prevent.stop="setNotification(2)">
        <span>{{ LangString('APP_TWITTER_NOTIFICATION_ALL') }}</span>
      </label>

      <label class="group checkbox" data-type="button" @click.prevent.stop="setNotification(1)">
        <input type="checkbox" :checked="twitterNotification === 1" @click.prevent.stop="setNotification(1)">
        <span>{{ LangString('APP_TWITTER_NOTIFICATION_MENTION') }}</span>
      </label>

      <label class="group checkbox" data-type="button" @click.prevent.stop="setNotification(0)">
        <input type="checkbox" :checked="twitterNotification === 0" @click.prevent.stop="setNotification(0)">
        <span>{{ LangString('APP_TWITTER_NOTIFICATION_NEVER') }}</span>
      </label>

      <div class="groupCheckBoxTitle">
        <label>{{ LangString('APP_TWITTER_NOTIFICATION_SOUND') }}</label>
      </div>

      <label class="group checkbox" data-type="button" @click.prevent.stop="setNotificationSound(true)">
        <input type="checkbox" :checked="twitterNotificationSound" @click.prevent.stop="setNotificationSound(true)">
        <span>{{ LangString('APP_TWITTER_NOTIFICATION_SOUND_YES') }}</span>
      </label>

      <label class="group checkbox" data-type="button" @click.prevent.stop="setNotificationSound(false)">
        <input type="checkbox" :checked="!twitterNotificationSound" @click.prevent.stop="setNotificationSound(false)">
        <span>{{ LangString('APP_TWITTER_NOTIFICATION_SOUND_NO') }}</span>
      </label>
    </template>

    <template v-else-if="state === STATES.ACCOUNT">
      <div style="margin-top: 42px; margin-bottom: 42px;" class="group img" data-type="button" @click.stop="onPressChangeAvartar">
        <img :src="twitterAvatarUrl" style="height: 64px; width: 64px;" @click.stop="onPressChangeAvartar">
        <input type='button' style="width: 170px;" class="btn btn-blue" :value="LangString('APP_TWITTER_ACCOUNT_AVATAR')" @click.stop="onPressChangeAvartar" />
      </div>

      <div class="group" data-type="button" @click.stop="changePassword">
        <input type='button' class="btn btn-red" :value="LangString('APP_TWITTER_ACCOUNT_CHANGE_PASSWORD')" @click.stop="changePassword"/>
      </div>
    </template>

  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import Modal from '@/components/Modal'
import { Switch } from 'mand-mobile'
import 'mand-mobile/lib/mand-mobile.css'

const STATES = Object.freeze({
  MENU: 0,
  NEW_ACCOUNT: 1,
  LOGIN: 2,
  ACCOUNT: 3,
  NOTIFICATION: 4
})

export default {
  name: 'twitter',
  components: {
    [Switch.name]: Switch
  },
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
    ...mapActions(['twitterLogin', 'twitterChangePassword', 'twitterLogout', 'twitterSetAvatar', 'twitterCreateNewAccount', 'setTwitterNotification', 'setTwitterNotificationSound']),
    handler (name, active) {
      console.log(`Status of switch ${name} is ${active ? 'active' : 'inactive'}`)
    },
    onUp: function () {
      if (this.ignoreControls === true) return
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
    onDown: function () {
      if (this.ignoreControls === true) return
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
    onEnter: function () {
      if (this.ignoreControls === true) return
      let select = document.querySelector('.group.select')
      if (select === null) return
      if (select.dataset !== null) {
        if (select.dataset.type === 'text') {
          const $input = select.querySelector('input')
          let options = {
            limit: parseInt(select.dataset.maxlength) || 64,
            text: select.dataset.defaultValue || '',
            title: select.dataset.title || ''
          }
          this.$phoneAPI.getReponseText(options).then(data => {
            $input.value = data.text
            $input.dispatchEvent(new window.Event('change'))
          })
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
    async setLocalAccountAvartar ($event) {
      try {
        this.ignoreControls = true
        let scelte = [
          {id: 1, title: this.LangString('APP_TWITTER_LINK_PICTURE'), icons: 'fa-link'},
          {id: 2, title: this.LangString('APP_TWITTER_TAKE_PICTURE'), icons: 'fa-camera'}
        ]
        const resp = await Modal.CreateModal({ scelte: scelte })
        if (resp.id === 1) {
          const data = await Modal.CreateTextModal({ text: this.twitterAvatarUrl || 'https://i.imgur.com/' })
          this.twitterSetAvatar({avatarUrl: data.text})
          this.ignoreControls = false
        } else if (resp.id === 2) {
          const pic = await this.$phoneAPI.takePhoto()
          if (pic && pic !== '') {
            if (this.localAccount.avatarUrl === null) {
              this.localAccount.avatarUrl = pic
              this.twitterAvatarUrl = pic
            }
            this.twitterSetAvatar({ avatarUrl: pic })
            this.ignoreControls = false
          }
        }
      } catch (e) {}
    },
    async onPressChangeAvartar () {
      try {
        this.ignoreControls = true
        let scelte = [
          {id: 1, title: this.LangString('APP_TWITTER_LINK_PICTURE'), icons: 'fa-link'},
          {id: 2, title: this.LangString('APP_TWITTER_TAKE_PICTURE'), icons: 'fa-camera'}
        ]
        const resp = await Modal.CreateModal({ scelte: scelte })
        if (resp.id === 1) {
          const data = await Modal.CreateTextModal({ text: this.twitterAvatarUrl || 'https://i.imgur.com/' })
          this.twitterSetAvatar({avatarUrl: data.text})
          this.ignoreControls = false
        } else if (resp.id === 2) {
          const pic = await this.$phoneAPI.takePhoto()
          if (pic && pic !== '') {
            if (this.localAccount.avatarUrl === null) {
              this.localAccount.avatarUrl = pic
              this.twitterAvatarUrl = pic
            }
            this.twitterSetAvatar({ avatarUrl: pic })
            this.ignoreControls = false
          }
        }
      } catch (e) {}
    },
    login () {
      this.twitterLogin({ username: this.localAccount.username, password: this.localAccount.password })
      this.state = STATES.MENU
    },
    logout () {
      this.twitterLogout()
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
        const password1 = await Modal.CreateTextModal({ limit: 30, title: 'Inserisci la nuova password' })
        if (password1.text === '') return
        const password2 = await Modal.CreateTextModal({ limit: 30, title: 'Ripeti la password' })
        if (password2.text === '') return
        if (password2.text !== password1.text) {
          this.$notify({
            title: this.LangString('APP_TWITTER_NAME'),
            message: this.LangString('APP_TWITTER_NOTIF_NEW_PASSWORD_MISS_MATCH'),
            icon: 'twitter',
            backgroundColor: '#e0245e80'
          })
          return
        } else if (password2.text.length < 6) {
          this.$notify({
            title: this.LangString('APP_TWITTER_NAME'),
            message: this.LangString('APP_TWITTER_NOTIF_NEW_PASSWORD_LENGTH_ERROR'),
            icon: 'twitter',
            backgroundColor: '#e0245e80'
          })
          return
        }
        this.twitterChangePassword(password2.text)
      } catch (e) {
        console.error(e)
      }
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
.content {
  /* margin: 6px 10px; */
  /* margin-top: 28px; */
  /* height: calc(100% - 48px); */
  display: flex;
  flex-direction: column;
  align-items: center;

  background-color: rgb(255, 255, 255);
}

.top-container {
  background-color: rgb(55, 161, 242);
  width: 100%;
  height: 60%;
  padding-top: 30%;
  position: absolute;
}

.group {
  position: relative;
  margin-top: 24px;
}

.group.inputText {
  position: relative;
  margin-top: 3%;
}

.group.inputText input {
  width: 300px;
  height: 40px;
  border: 0;
  border-radius: 15px;
  font-size: 14px;
  padding: 26px 0px;
  padding-left: 38px;
  margin: auto;
  color: rgb(35, 51, 76);
}

.group.inputText i {
  position: absolute;
  top: 15px;
  left: 12px;
  border-radius: 15px;
  font-size: 21px;
  color: rgb(55, 161, 242);
}

.group.bottom {
  margin-top: auto;
}

.group.img {
  display: flex;
  flex-direction: row;
  align-items: center;
}

.group.img img {
  width: 0;
  height: 60px;
  overflow: auto;

  display: flex;
  flex-direction: row;
  overflow: auto;
  flex-grow: 0;
  flex: 0 0 64px;
  margin-right: 12px;
  border-radius: 100px;
  object-fit: cover;
}

input {
  font-size: 24px;
  display: block;
  width: 314px;
  border:none;
  border-bottom: 1px solid #757575;
}
input:focus { outline:none; }

/* LABEL ======================================= */
.group.inputText label {
  color:#999;
  font-size:18px;
  font-weight:normal;
  position:absolute;
  pointer-events:none;
  left:5px;
  top:10px;
  transition:0.2s ease all;
  -moz-transition:0.2s ease all;
  -webkit-transition:0.2s ease all;
}

.checkbox {
  display: flex;
  height: 42px;
  line-height: 42px;
  align-items: center;
  color: grey;
  font-weight: 200;
  border-radius: 6px;
  padding-left: 12px;
  margin-top: 4px;
}

.checkbox span {
  padding-right: 45px;
}

.checkbox input {
  width: 24px;
  height: 0px;
  opacity: 1;
}

.checkbox input::after {
  box-sizing: border-box;
  content: '';
  opacity: 1;
  position: absolute;
  left: 6px;
  margin-top: -10px;
  width: 15px;
  height: 15px;
  background-color: white;
  border: 3px rgb(55, 161, 242) solid;
  border-radius: 50%;
}

.checkbox input:checked::after {
  background-color: rgb(55, 161, 242);
}

.checkbox.select {
  border: 1px solid rgb(55, 161, 242);
}

.groupCheckBoxTitle {
  margin-top: 12px;
}

.groupCheckBoxTitle label {
  font-weight: bold;
  font-size: 20px;
  color: rgb(0, 0, 0);
}

/* active state */
.group.inputText input:focus ~ label, .group.inputText input:valid ~ label 		{
  top: -24px;
  font-size: 18px;
  color: #007bff85;
}

/* BOTTOM BARS ================================= */
.bar 	{ position:relative; display:block; width:100%; }
.bar:before, .bar:after {
  content: '';
  height: 2px;
  width: 0;
  bottom: 1px;
  position: absolute;
  background: #007bff85;
  transition: 0.2s ease all;
}

.bar:before {
  left: 50%;
}

.bar:after {
  right: 50%;
}

/* active state */
input:focus ~ .bar:before, input:focus ~ .bar:after,
.group.select input ~ .bar:before, .group.select input ~ .bar:after{
  width: 45%;
}

/* HIGHLIGHTER ================================== */
.highlight {
  position: absolute;
  height: 60%;
  width: 100px;
  top: 25%;
  left: 0;
  pointer-events: none;
  opacity: 0.5;
}

/* active state */
input:focus ~ .highlight {
  -webkit-animation: inputHighlighter 0.3s ease;
  -moz-animation: inputHighlighter 0.3s ease;
  animation: inputHighlighter 0.3s ease;
}

.group .btn {
  width: 100%;
  padding: 0px 0px;
  height: 48px;
  color: #fff;
  border: 0 none;
  font-size: 22px;
  font-weight: 500;
  line-height: 34px;
  color: #202129;
  background-color: #edeeee;
}

.group.select .btn {
  /* border: 6px solid #C0C0C0; */
  line-height: 18px;
}

.group .btn.btn-blue {
  width: 293px;
  margin: auto;
  margin-bottom: 10px;
  text-align: center;
  border: 1px solid rgb(55, 161, 242);
  color: rgb(55, 161, 242);
  background-color: white;
  border-radius: 100px;
  font-weight: 100;
  font-size: 14px;
}

.group .btn.btn-blue2 {
  width: 293px;
  margin: auto;
  margin-bottom: 10px;
  text-align: center;
  border: 1px solid rgb(55, 161, 242);
  color: rgb(55, 161, 242);
  background-color: white;
  border-radius: 100px;
  font-weight: 100;
  font-size: 14px;
}

.group.select .btn.btn-blue {
  background-color: rgb(55, 161, 242);
  color: white;
  border: none;
}

.group.select .btn.btn-blue2 {
  background-color: rgb(32, 95, 143);
  color: white;
  border: none;
}

.group .btn.btn-red {
  border: 1px solid #ee3838;
  color: #ee3838;
  background-color: white;
  font-weight: 100;
  font-size: 14px;;
  border-radius: 100px;
  width: 293px;
  margin: 0 auto;
  margin-bottom: 50px;
}
.group.select .btn.btn-red, .btn.btn-red {
  background-color: #ee3838;
  color: white;
  border: none;
}


.group .btn.btn-grey {
  width: 293px;
  margin: auto;
  margin-bottom: 10px;
  text-align: center;
  border: 1px solid rgb(55, 161, 242);
  color: rgb(55, 161, 242);
  background-color: rgb(68, 68, 68);
  border-radius: 100px;
  font-weight: 100;
  font-size: 14px;
}

.group.select .btn.btn-gray, .btn.btn-gray {
  background-color: rgb(110, 118, 125);
  color: white;
  border: none;
}

/* ANIMATIONS ================ */
@-webkit-keyframes inputHighlighter {
	from { background:#007aff; }
  to 	{ width:0; background:transparent; }
}

@-moz-keyframes inputHighlighter {
	from { background:#007aff; }
  to 	{ width:0; background:transparent; }
}

@keyframes inputHighlighter {
	from { background:#007aff; }
  to 	{ width:0; background:transparent; }
}
</style>
