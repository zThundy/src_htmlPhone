<template>
  <div style="width: 100%; height: 735px; overflow: hidden; background-color: rgb(30, 50, 75);" class="phone_app">
    <PhoneTitle :title="currentScreen.title" :color="'white'" backgroundColor="rgb(55, 161, 242)" v-on:back="quit"/>
    
    <div class="phone_content">
      <component v-bind:is="currentScreen.component"/>
    </div>

    <div class="twitter_menu">
      <div v-for="(s, i) in screen" :key="i" class="twitter_menu-item" :class="{ select: i === currentScreenIndex }">
        <i class="fa" :class="s.icon"></i>
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
    ...mapGetters(['LangString']),
    screen () {
      return [
        {
          title: this.LangString('APP_TWITTER_VIEW_TWITTER'),
          component: TwitterView,
          icon: 'fa-home'
        },
        {
          title: this.LangString('APP_TWITTER_VIEW_TOP_TWEETS'),
          component: TwitterTopTweet,
          icon: 'fa-heart'
        },
        {
          title: this.LangString('APP_TWITTER_VIEW_TWEETER'),
          component: TwitterPostTweet,
          icon: ' fa-comment-o'
        },
        {
          title: this.LangString('APP_TWITTER_VIEW_SETTING'),
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
      //   backgroundColor: 'rgb(55, 55, 255)',
      //   appName: 'Twitter'
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
      //   appName: 'Instagram'
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
  border-top: 1px solid rgb(110, 118, 125);
  height: 56px;
  display: flex;
  width: 100%;
  background-color: rgb(55, 161, 242);
}

.twitter_menu-item {
  flex-grow: 1;
  flex-basis: 0;
  display: flex;
  justify-content: center;
  align-items: center;

  color: rgb(110, 118, 125);
  background-color: rgb(255, 255, 255);
}

.twitter_menu-item.select {
  color: rgb(55, 161, 242);
}

</style>
