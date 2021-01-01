<template>
  <div style="width: 326px; height: 743px;" class="phone_app">
    <PhoneTitle :title="currentScreen.title" backgroundColor="#1da1f2" v-on:back="quit"/>
    
    <div class="phone_content">
      <component v-bind:is="currentScreen.component"/>
    </div>

    <div class="twitter_menu">

      <div v-for="(s, i) in screen" :key="i" class="twitter_menu-item" :class="{select: i === currentScreenIndex}" @click.stop="openMenu(i)">

        <i class="fa" :class="s.icon" @click.stop="openMenu(i)"></i>

      </div>

    </div>
  </div>
</template>

<script>
import PhoneTitle from './../PhoneTitle'
import TwitterView from './TwitterView'
import TwitterPostTweet from './TwitterPostTweet'
import TwitterAccount from './TwitterAccount'
import TwitterTopTweet from './TwitterTopTweet'
import { mapGetters } from 'vuex'
// import Vue from 'vue'

export default {
  name: 'twitter-screen',
  components: { PhoneTitle },
  data () {
    return {
      currentScreenIndex: 0
    }
  },
  computed: {
    ...mapGetters(['IntlString']),
    screen () {
      return [
        {
          title: this.IntlString('APP_TWITTER_VIEW_TWITTER'),
          component: TwitterView,
          icon: 'fa-home'
        },
        {
          title: this.IntlString('APP_TWITTER_VIEW_TOP_TWEETS'),
          component: TwitterTopTweet,
          icon: 'fa-heart'
        },
        {
          title: this.IntlString('APP_TWITTER_VIEW_TWEETER'),
          component: TwitterPostTweet,
          icon: ' fa-comment-o'
        },
        {
          title: this.IntlString('APP_TWITTER_VIEW_SETTING'),
          component: TwitterAccount,
          icon: 'fa-cog'
        }
      ]
    },
    currentScreen () {
      return this.screen[this.currentScreenIndex]
    }
  },
  watch: {
  },
  methods: {
    onLeft () {
      this.currentScreenIndex = Math.max(0, this.currentScreenIndex - 1)
      // Vue.notify({
      //   message: 'messaggio messaggio messaggio messaggio messaggio messaggio messaggio messaggio messaggio messaggio messaggio messaggio ',
      //   title: 'autore' + ' : SONO FIKO',
      //   icon: 'twitter',
      //   sound: 'Twitter_Sound_Effect.ogg'
      // })
      // Vue.notify({
      //   title: 'autore' + ' : SONO FIKO',
      //   message: 'messaggio messaggio messaggio messaggio messaggio messaggio messaggio messaggio messaggio messaggio messaggio messaggio ',
      //   icon: 'instagram',
      //   backgroundColor: '#66000080',
      //   sound: 'Instagram_Error.ogg'
      // })
      // Vue.notify({
      //   title: 'autore' + ' : SONO FIKO',
      //   message: 'messaggio messaggio messaggio messaggio messaggio messaggio messaggio messaggio messaggio messaggio messaggio messaggio ',
      //   icon: 'instagram',
      //   backgroundColor: '#FF66FF80',
      //   sound: 'Instagram_Notification.ogg'
      // })
    },
    onRight () {
      this.currentScreenIndex = Math.min(this.screen.length - 1, this.currentScreenIndex + 1)
      // Vue.notify({
      //   message: 'messaggio messaggio messaggio messaggio messaggio messaggio messaggio messaggio messaggio messaggio messaggio messaggio ',
      //   title: 'autore' + ' : SONO FIKO',
      //   icon: 'twitter',
      //   sound: 'Twitter_Sound_Effect.ogg'
      // })
    },
    home () {
      this.currentScreenIndex = 0
    },
    openMenu (index) {
      this.currentScreenIndex = index
    },
    quit () {
      if (this.currentScreenIndex === 0) {
        this.$router.push({ name: 'menu' })
      } else {
        this.currentScreenIndex = 0
      }
    }
  },
  created () {
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('twitterHome', this.home)
  },
  mounted () {
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('twitterHome', this.home)
  }
}
</script>

<style scoped>
.twitter_menu {
  border-top: 1px solid #CCC;
  height: 56px;
  display: flex;
  width: 100%;
}

.twitter_menu-item {
  flex-grow: 1;
  flex-basis: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  color: #959595;
}

.twitter_menu-item.select {
  color: #1da1f2;
}

.twitter_menu-item:hover {
  color: #1da1f2;
}

</style>
