<template>
  <div>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cssgram/0.1.10/cssgram.min.css">
    <!-- <link rel="stylesheet" href="https://cssgram-cssgram.netdna-ssl.com/cssgram.min.css"> -->

    <div class="posts" v-for='(post, key) in instaPosts' v-bind:key="post.id" v-bind:class="{ select: key === selectMessage }">
      
      <div class="instagram-profile-picture">
        <img :src="post.authorIcon || 'html/static/img/app_instagram/default_profile.png'" width="48" height="48" style="object-fit: cover;"/>
        <div class="instagram-head-author">{{ post.author }}</div>
        <div class="instagram-head-time">{{ formatTime(post.data) }}</div>
      </div>

      <div class="instagram-content">
        <div class="instagram-post-picture">
          <img :class="post.filter" v-if="isImage(post.image)" :src="post.image" class="instagram-image">
        </div>

        <div class="instagram-like">
          <div v-if="post.isLike" class="item svgdislike">
            <i class="fa fa-heart" aria-hidden="true"/>
            <span>{{ post.likes }}</span>
          </div>

          <div v-else class="svglike">
            <i class="fa fa-heart-o" aria-hidden="true"/>
            <span>{{ post.likes }}</span>
          </div>
        </div>

        <div class="descrizione_post">{{ formatEmoji(post.didascalia) }}</div>
      </div>
    </div>

  </div>
</template>

<script>
import { mapGetters, mapActions, mapMutations } from 'vuex'
import Modal from '@/components/Modal/index.js'

export default {
  components: {},
  data () {
    return {
      selectMessage: -1,
      ignoreControls: false
    }
  },
  computed: {
    ...mapGetters(['instaPosts', 'LangString', 'igAccount'])
  },
  // watch: {},
  methods: {
    ...mapActions(['instagramPostTweet', 'instagramToogleLike']),
    ...mapMutations(['CHANGE_BRIGHTNESS_STATE']),
    formatEmoji (message) {
      return this.$phoneAPI.convertEmoji(message)
    },
    async showOption () {
      this.ignoreControls = true
      const post = this.instaPosts[this.selectMessage]
      Modal.CreateModal({ scelte: [
        { id: 1, title: this.LangString('APP_TWITTER_LIKE'), icons: 'fa-heart' },
        { id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' }
      ] })
      .then(resp => {
        this.ignoreControls = false
        switch (resp.id) {
          case 1:
            this.$phoneAPI.instagram_toggleLikePost(this.igAccount.username, this.igAccount.password, post.id)
            break
          case -1:
            this.ignoreControls = false
            break
        }
      })
      .catch(e => { this.ignoreControls = false })
    },
    isImage (mess) {
      return this.$phoneAPI.isLink(mess)
    },
    resetScroll () {
      this.$nextTick(() => {
        let elem = document.querySelector('#posts')
        elem.scrollTop = elem.scrollHeight
        this.selectMessage = -1
      })
    },
    scrollIntoView () {
      this.$nextTick(() => {
        const elem = this.$el.querySelector('.select')
        if (elem !== null) {
          elem.scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' })
        }
      })
    },
    onUp () {
      if (this.ignoreControls) return
      if (this.selectMessage === -1) {
        this.selectMessage = 0
      } else {
        this.selectMessage = this.selectMessage === 0 ? 0 : this.selectMessage - 1
      }
      this.scrollIntoView()
    },
    onDown () {
      if (this.ignoreControls) return
      if (this.selectMessage === -1) {
        this.selectMessage = 0
      } else {
        this.selectMessage = this.selectMessage === this.instaPosts.length - 1 ? this.selectMessage : this.selectMessage + 1
      }
      this.scrollIntoView()
    },
    async onEnter () {
      if (this.ignoreControls) return
      if (this.selectMessage !== -1) {
        this.showOption()
      }
    },
    onBack () {
      if (this.ignoreControls) return
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
    this.$phoneAPI.instagram_getPosts(this.igAccount.username, this.igAccount.password)
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
  background-color: rgb(230, 230, 230);
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
