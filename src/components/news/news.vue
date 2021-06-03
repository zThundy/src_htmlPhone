<template>
  <div class="phone_app">
    <PhoneTitle :title="LangString('APP_NEWS_TITLE')" :color="'white'" :backgroundColor="'rgb(106, 104, 231)'" />

    <div class="phone_fullscreen_img" v-if="imgZoom !== undefined">
      <img :src="imgZoom" />
    </div>

    <div class="journals-container">
      <div v-if="currentModule === 0">
        <div v-for="(elem, key) of news" :key="key" :class="{ select: currentSelect === key }" class="journal-container">
          <md-swiper
            v-if="elem.pics && elem.pics.length > 0"
            class="journal-swiper-container"
            :autoplay="5000"
            :transition-duration="600"
            ref="swiper"
            @after-change="afterChange"
          >
            <md-swiper-item class="journal-swiper-item" v-for="(pic, key) of elem.pics" :key="key">
              <img :src="pic"/>
            </md-swiper-item>
          </md-swiper>

          <div class="journal-message-container">
            <p v-if="elem.messages && elem.message.length > 0">{{ formatEmoji(elem.message) }}</p>
            <timeago class="journal-message-timeago" :since='elem.time' :auto-update="20"></timeago>
          </div>
        </div>
      </div>

      <div v-if="currentModule === 1">
        <div class="bottoni">
          <div class="bottone">
            <input type='button' :value="LangString('APP_NEWS_UPLOAD_PICTURE')" :class="{ select: currentSelect === 0 }"/>
          </div>

          <div class="bottone">
            <input type='button' :value="LangString('APP_NEWS_WRITE_MESSAGE')" :class="{ select: currentSelect === 1 }"/>
          </div>

          <div class="bottone">
            <input type='button' :value="LangString('APP_NEWS_SEND_POST')" :class="{ select: currentSelect === 2 }"/>
          </div>
        </div>

        <div class="journal-container">
          <md-swiper v-if="tempNews.pics && tempNews.pics.length > 0" class="journal-swiper-container" :autoplay="5000" :transition-duration="600" ref="swiper">
            <md-swiper-item class="journal-swiper-item" v-for="(pic, key) of tempNews.pics" :key="key">
              <img :src="pic"/>
            </md-swiper-item>
          </md-swiper>

          <div v-if="tempNews.description && tempNews.description.length > 0" class="journal-message-container">
            <p>{{ formatEmoji(tempNews.description) }}</p>
          </div>
        </div>
      </div>
    </div>
    
    <div class="journal-footer" v-if="config.weazelJob[job]">
      <div class="journal-footer-item" :class="{ selected: 0 === currentModule }">
        <i class="fa fa-newspaper-o"></i>
      </div>
      <div class="journal-footer-item" :class="{ selected: 1 === currentModule }">
        <i class="fa fa-pencil"></i>
      </div>
    </div>

  </div>
</template>

<script>
import { mapGetters, mapMutations } from 'vuex'
import PhoneTitle from './../PhoneTitle'
import Modal from '@/components/Modal/index'

import { Swiper, SwiperItem } from 'mand-mobile'
import 'mand-mobile/lib/mand-mobile.css'

export default {
  name: 'email',
  components: {
    PhoneTitle,
    [Swiper.name]: Swiper,
    [SwiperItem.name]: SwiperItem
  },
  data () {
    return {
      currentSelect: -1,
      currentModule: 0,
      ignoreControl: false,
      currentPicIndex: 0,
      imgZoom: undefined
    }
  },
  computed: {
    ...mapGetters(['LangString', 'news', 'job', 'tempNews', 'config'])
  },
  methods: {
    ...mapMutations(['UPDATE_TEMP_INFO', 'CHANGE_BRIGHTNESS_STATE']),
    // listening
    // beforeChange(from, to) {
    //   this.setValue('#valueSwiper0', from)
    //   this.setValue('#valueSwiper1', to)
    // },
    afterChange (from, to) {
      this.currentPicIndex = to
    },
    formatEmoji (message) {
      return this.$phoneAPI.convertEmoji(message)
    },
    scrollIntoView () {
      this.$nextTick(() => {
        const elem = this.$el.querySelector('.select')
        if (elem !== null) {
          elem.scrollIntoView()
        }
      })
    },
    onBackspace () {
      if (this.imgZoom !== undefined) {
        this.imgZoom = undefined
        this.CHANGE_BRIGHTNESS_STATE(true)
        return
      }
      if (this.ignoreControl) {
        this.ignoreControl = false
        return
      }
      this.$router.push({ name: 'menu' })
    },
    async onEnter () {
      if (this.ignoreControl) return
      if (this.currentModule === 0) {
        if (this.news[this.currentSelect] && this.news[this.currentSelect].pics && this.news[this.currentSelect].pics.length > 0) {
          this.imgZoom = this.news[this.currentSelect].pics[this.currentPicIndex]
          this.CHANGE_BRIGHTNESS_STATE(false)
        }
      } else {
        if (this.currentSelect === 0) {
          // carica immagine
          this.ignoreControl = true
          var options = [
            { id: 1, title: this.LangString('APP_CONFIG_LINK_PICTURE'), icons: 'fa-link' },
            { id: 2, title: this.LangString('APP_CONFIG_TAKE_PICTURE'), icons: 'fa-camera' },
            { id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' }
          ]
          Modal.CreateModal({ choix: options }).then(resp => {
            switch (resp.id) {
              case 1:
                Modal.CreateTextModal({ text: 'https://i.imgur.com/' }).then(value => {
                  if (value.text !== '' && value.text !== undefined && value.text !== null && value.text !== 'https://i.imgur.com/') {
                    // this.tempPics.push(value.text)
                    this.UPDATE_TEMP_INFO({ type: 'pic', text: value.text })
                    this.ignoreControl = false
                  }
                })
                break
              case 2:
                this.$phoneAPI.takePhoto().then(pic => {
                  // this.tempPics.push(pic.url)
                  this.UPDATE_TEMP_INFO({ type: 'pic', text: pic.url })
                  this.ignoreControl = false
                })
                break
              case -1:
                this.ignoreControl = false
                break
            }
          })
        } else if (this.currentSelect === 1) {
          // scrivi descrizione
          Modal.CreateTextModal({ text: '' }).then(value => {
            if (value.text !== '' && value.text !== undefined && value.text !== null) {
              // this.tempDescription = value.text
              this.UPDATE_TEMP_INFO({ type: 'description', text: value.text })
              this.ignoreControl = false
            }
          })
        } else if (this.currentSelect === 2) {
          // posta news
          if (this.tempNews.pics.length > 0 || this.tempDescription !== '') {
            this.$phoneAPI.postNews(this.tempNews.pics, this.tempNews.description)
            this.UPDATE_TEMP_INFO({ type: 'clear' })
          } else {
            this.$phoneAPI.sendErrorMessage('Devi compilare almeno un campo per poter postare una news')
          }
          this.$phoneAPI.fetchNews()
        }
      }
    },
    async onRight () {
      if (this.ignoreControl) return
      if (!this.config.weazelJob[this.job]) return
      if (this.currentModule === 1) return
      this.currentModule = this.currentModule + 1
      this.currentSelect = -1
    },
    async onLeft () {
      if (this.ignoreControl) return
      if (this.currentModule === 0) return
      this.currentModule = this.currentModule - 1
      this.currentSelect = -1
    },
    onUp () {
      if (this.ignoreControl) return
      if (this.currentSelect === -1) return
      this.currentSelect = this.currentSelect - 1
      this.scrollIntoView()
    },
    onDown () {
      if (this.ignoreControl) return
      if (this.currentModule === 0) {
        if (this.currentSelect === this.news.length - 1) return
      } else {
        if (this.currentSelect === 2) return
      }
      this.currentSelect = this.currentSelect + 1
      this.scrollIntoView()
    },
    formatTime (time) {
      const dateObject = new Date(time)
      var hours = dateObject.getHours()
      var minutes = dateObject.getMinutes()
      if (minutes < 10) minutes = '0' + minutes
      if (hours < 10) hours = '0' + hours
      return hours + ':' + minutes
    }
  },
  created () {
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpArrowDown', this.onDown)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpArrowDown', this.onDown)
  }
}
</script>

<style scoped>
.journals-container {
  position: relative;
  width: 100%;
  height: 100%;
  overflow: auto;
}

.journal-container {
  position: relative;
  width: 100%;
  height: auto;

  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.journal-swiper-container {
  color: black;
  height: 250px;
}

.journal-swiper-item {
  color: black;
}

.journal-swiper-item img {
  object-fit: contain;
  align-content: center;
  height: 100%;
  width: 100%;
}

.journal-message-container {
  position: relative;
  width: 95%;
  height: auto;

  padding-top: 10px;
  padding-bottom: 10px;

  overflow: auto;
}

.journal-message-container p {
  font-family: SanFrancisco;
  font-size: 15px;
  text-align: center;
}

.journal-message-timeago {
  position: absolute;
  font-size: 10px;
  right: 10px;
  bottom: 8px;
}

.journal-container.select {
  background-color: rgba(124, 122, 255, 0.4);
}

.journal-footer {
  position: sticky;
  border-top: 1px solid #CCC;
  height: 56px;
  display: flex;
  width: 100%;
}

.journal-footer-item {
  flex-grow: 1;
  flex-basis: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  color: #959595;
}

.selected {
  color: rgb(148, 146, 253);
}

/* /////// */
/* BOTTONI */
/* //////// */

.bottoni {
  position: relative;

  height: 25%;
  width: 100%;

  display: flex;
  flex-direction: column;

  align-items: center;
  justify-content: center;
  align-content: center;

  margin-top: 10%;
}

.bottone {
  position: relative;

  height: 80px;
}

.bottone input {
  border-radius: 20px;
  border-style: hidden;

  height: 50px;
  width: 250px;
}

.bottone .select {
  background-color: rgba(151, 187, 255, 0.5);
}
</style>
