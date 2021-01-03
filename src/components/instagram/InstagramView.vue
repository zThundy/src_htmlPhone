<template>
  <div style="width: 326px; height: 743px;" class="phone_content">
    <link rel="stylesheet" href="https://cssgram-cssgram.netdna-ssl.com/cssgram.min.css">

    <div class="phone_fullscreen_img" v-if="imgZoom !== undefined" @click.stop="imgZoom = undefined">
      <img :src="imgZoom" />
    </div>

    <div class="posts" v-for='(post, key) in instaPosts' v-bind:key="post.id" v-bind:class="{ select: key === selectMessage }">
      
      <div class="instagram-profile-picture">
        <img :src="post.authorIcon || 'html/static/img/app_instagram/default_profile.png'" width="48" height="48" style="object-fit: cover;"/>
        <div class="instagram-head-author">{{ post.author }}</div>
        <div class="instagram-head-time">{{ formatTime(post.data) }}</div>
      </div>

      <div class="instagram-content">

        <div class="instagram-post-picture">
          <img :class="post.filter" v-if="isImage(post.image)" :src="post.image" class="instagram-image" @click.stop="imgZoom = post.image">
        </div>

        <div class="instagram-like">

          <div v-if="post.isLike" class="item svgdislike" @click.stop="instagramToogleLike(post.id)">     
              <svg @click.stop="instagramToogleLike(post.id)" xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"><path d="M0 0h24v24H0z" fill="none"/><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>
              <span @click.stop="instagramToogleLike(post.id)">{{ post.likes }}</span>
          </div>

          <div v-else class="svglike" @click.stop="instagramToogleLike(post.id)">
              <svg @click.stop="instagramToogleLike(post.id)" xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"><path d="M0 0h24v24H0z" fill="none"/><path d="M16.5 3c-1.74 0-3.41.81-4.5 2.09C10.91 3.81 9.24 3 7.5 3 4.42 3 2 5.42 2 8.5c0 3.78 3.4 6.86 8.55 11.54L12 21.35l1.45-1.32C18.6 15.36 22 12.28 22 8.5 22 5.42 19.58 3 16.5 3zm-4.4 15.55l-.1.1-.1-.1C7.14 14.24 4 11.39 4 8.5 4 6.5 5.5 5 7.5 5c1.54 0 3.04.99 3.57 2.36h1.87C13.46 5.99 14.96 5 16.5 5c2 0 3.5 1.5 3.5 3.5 0 2.89-3.14 5.74-7.9 10.05z"/></svg>
              <span @click.stop="instagramToogleLike(post.id)">{{ post.likes }}</span>
          </div>

        </div>

        <div class="descrizione_post">{{ post.didascalia }}</div>
        
      </div>
    </div>

  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import Modal from '@/components/Modal/index.js'
import PhoneAPI from './../../PhoneAPI'

export default {
  components: {},
  data () {
    return {
      selectMessage: -1,
      ignoreControls: false,
      imgZoom: undefined
    }
  },
  computed: {
    ...mapGetters(['instaPosts', 'IntlString', 'instagramUsername', 'instagramPassword'])
  },
  watch: {
  },
  methods: {
    ...mapActions(['instagramLogin', 'instagramPostTweet', 'instagramToogleLike']),
    async showOption () {
      this.ignoreControls = true
      const post = this.instaPosts[this.selectMessage]
      let optionsChoix = [{
        id: 1,
        title: this.IntlString('APP_TWITTER_LIKE'),
        icons: 'fa-heart'
      }, {
        // id: 2,
        // title: this.IntlString('APP_MESSAGE_ZOOM_IMG'),
        // icons: 'fa-search'
      // }, {
        id: -1,
        title: this.IntlString('CANCEL'),
        icons: 'fa-undo'
      }]
      const choix = await Modal.CreateModal({ choix: optionsChoix })
      this.ignoreControls = false
      switch (choix.id) {
        case 1:
          this.instagramToogleLike(post.id)
          break
        case 2:
          this.imgZoom = post.message
          break
      }
    },
    isImage (mess) {
      return /^https?:\/\/.*\.(png|jpg|jpeg|gif)/.test(mess)
    },
    resetScroll () {
      this.$nextTick(() => {
        let elem = document.querySelector('#posts')
        elem.scrollTop = elem.scrollHeight
        this.selectMessage = -1
      })
    },
    scrollIntoViewIfNeeded () {
      this.$nextTick(() => {
        const elem = this.$el.querySelector('.select')
        if (elem !== null) {
          elem.scrollIntoViewIfNeeded()
        }
      })
    },
    onUp () {
      if (this.ignoreControls === true) return
      if (this.selectMessage === -1) {
        this.selectMessage = 0
      } else {
        this.selectMessage = this.selectMessage === 0 ? 0 : this.selectMessage - 1
      }
      this.scrollIntoViewIfNeeded()
    },
    onDown () {
      if (this.ignoreControls === true) return
      if (this.selectMessage === -1) {
        this.selectMessage = 0
      } else {
        this.selectMessage = this.selectMessage === this.instaPosts.length - 1 ? this.selectMessage : this.selectMessage + 1
      }
      this.scrollIntoViewIfNeeded()
    },
    async onEnter () {
      if (this.ignoreControls === true) return
      if (this.selectMessage !== -1) {
        this.showOption()
      }
    },
    onBack () {
      if (this.imgZoom !== undefined) {
        this.imgZoom = undefined
        return
      }
      if (this.ignoreControls === true) return
      if (this.selectMessage !== -1) {
        this.selectMessage = -1
      } else {
        this.$router.push({ name: 'menu' })
      }
    },
    formatTime (time) {
      const d = new Date(time)
      return d.toLocaleTimeString()
    }
  },
  created () {
    PhoneAPI.instagram_getPosts(this.instagramUsername, this.instagramPassword)

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

/* ##################### */
/* CONTROLLI INTERAZIONI */
/* ##################### */

.svglike:hover {
  cursor: pointer;
  fill: red;
  color: red;
}

.svgdislike {
  fill: red;
  color: red;
}

.svgdislike:hover {
  cursor: pointer;
  fill: #6b0000;
  color: #6b0000;
}

/* ########################## */
/* DIV PRINCIPALE "CONTAINER" */
/* ########################## */

.posts {
  background-color: white;
  width: 100%;
  display: ruby-base-container;
  border-bottom: rgba(250, 103, 225, 0.178) 1px solid;
  padding-top: 8px;
}

.posts.select {
  background-color: #fac1f77e;
}

.instagram-profile-picture {
  width: 322px;
  display: flex;
  position: left;
  padding-left: 10px;
  justify-content: left;
}

.instagram-profile-picture img {
  border-radius: 50%;
  border-style: outset;
  border-width: 1px;
  border-color: rgba(0, 0, 0, 0.603);
}

.instagram-content {
  bottom: 10px;
  width: 100%;
  position: relative;
}

/* ######################### */
/* CONTENUTO TESTA MESSAGGIO */
/* ######################### */

.instagram-head {
  padding-top: 10px;
  bottom: 20px;
  font-size: 14px;
  position: left;
}

.instagram-head-author {
  width: 100%;
  padding-left: 5px;
}

.instagram-head-time {
  font-size: 12px;
  padding-top: 5px;
  padding-right: 5px;
  text-align: right;
  color: rgb(125, 98, 126);
}

/* ################ */
/* MESSAGGI SINGOLI */
/* ################ */

.instagram-post-picture {
  right: 20px;
}

.instagram-image {
  padding-top: 30px;
  width: 100%;
  align-content: flex-start;
  display: flex;
}

.instagram-like {
  margin-top: 6px;
  padding-left: 10px;
  display: flex;
  width: 100%;
  height: 20px;
  font-size: 12px;
  line-height: 24px;
  font-weight: 700;
}

.instagram-like div {
  width: 80px;
}

.tweet_write {
  height: 56px;
  widows: 100%;
  background: #edc0e3;
  display: flex;
  justify-content: space-around;
  align-items: center;
}

.tweet_write input{
    width: 75%;
    margin-left: 6%;
    border: none;
    outline: none;
    font-size: 16px;
    padding: 3px 12px;
    float: left;
    height: 36px;
    background-color: #ffffff;
    color: white;
    border-radius: 16px;
}

.tweet_write input::placeholder {
  color: #888;
}

.tweet_send{
    width: 32px;
    height: 32px;
    float: right;
    border-radius: 50%;
    background-color: #eb1df2;
    margin-right: 12px;
    margin-bottom: 2px;
    color: white;
    line-height: 32px;
    text-align: center;
}

.elements::-webkit-scrollbar-track {
  box-shadow: inset 0 0 6px rgba(0,0,0,0.3);
  background-color: #a6a28c;
}

.elements::-webkit-scrollbar {
  width: 3px;
  background-color: transparent;
}

.elements::-webkit-scrollbar-thumb {
  background-color: #eb1df2;
}

.descrizione_post {
  padding-left: 10px;
  padding-top: 2px;
  font-size: 15px;
}
</style>
