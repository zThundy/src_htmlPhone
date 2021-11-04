<template>
  <div class="notifications">

    <!-- <div v-for='notif in list' :key="notif.id" class="notification"> -->
    <div v-if="currentShowing" class="notification">
      <div class="appName" :style="style(currentShowing)">
        <i v-if="currentShowing.icon" class="fa" :class="'fa-' + currentShowing.icon"/>
        <span>{{ currentShowing.appName }}</span>
      </div>

      <div class="divider"></div>

      <div v-if="currentShowing.title" class="message-title">{{ formatEmoji(currentShowing.title) }}</div>
      <div v-if="currentShowing.message" class="message">{{ checkAdditionalFormat(formatEmoji(currentShowing.message)) }}</div>
    </div>

  </div>
</template>

<script>
import events from './events'
import { mapGetters } from 'vuex'

export default {
  components: { },
  data () {
    return {
      currentId: 0,
      list: [],
      soundList: {},
      currentShowing: null,
      audioElement: new Audio()
    }
  },
  mounted () {
    events.$on('add', this.addItem)
  },
  computed: {
    ...mapGetters(['show', 'volume', 'LangString'])
  },
  methods: {
    formatEmoji (message) {
      return this.$phoneAPI.convertEmoji(message)
    },
    checkAdditionalFormat (message) {
      if (message.indexOf('[AUDIO]') === 0) {
        return this.LangString('PHONE_AUDIO_MESSAGE_TITLE')
      }
      if (message.indexOf('[CONTACT]') === 0) {
        return this.LangString('PHONE_CONTACT_MESSAGE_TITILE')
      }
      if (message.indexOf('[VIDEO]') === 0) {
        return this.LangString('PHONE_VIDEO_MESSAGE_TITLE')
      }
      if (this.$phoneAPI.isLink(message)) {
        return this.LangString('PHONE_IMAGE_MESSAGE_TITLE')
      }
      return message
    },
    async addItem (event = {}) {
      const dataNotif = { ...event, id: this.currentId++, duration: parseInt(event.duration) || 3000 }
      if (dataNotif.sound) {
        // var path = '/html/static/sound/' + dataNotif.sound
        if (dataNotif.sound === undefined || dataNotif.sound === null) return
        // if (this.soundList[dataNotif.id] !== undefined) {
        //   this.soundList[dataNotif.id].volume = Number(this.volume)
        // } else {
        //   this.audioElement.src = path
        //   this.audioElement.volume = Number(this.volume)
        //   this.soundList[dataNotif.id] = this.audioElement
        // }
      }
      if (!event.hidden) {
        this.list.push(dataNotif)
        if (this.currentShowing === null) this.showNotification(dataNotif)
      } else {
        this.$phoneAPI.onplaySound({ volume: this.volume, sound: dataNotif.sound, loop: false })
      }
    },
    showNotification (dataNotif) {
      this.currentShowing = dataNotif
      // if (this.soundList[dataNotif.id]) { this.soundList[dataNotif.id].play() }
      this.$phoneAPI.onplaySound({ volume: this.volume, sound: this.currentShowing.sound, loop: false })
      setTimeout(() => {
        if (this.currentShowing === null || this.currentShowing === undefined) return
        this.list = this.list.filter(n => n.id !== this.currentShowing.id)
        // delete this.soundList[this.currentShowing.id]
        this.currentShowing = null
        setTimeout(() => {
          if (this.list[0]) { this.showNotification(this.list[0]) }
        }, 200)
      }, dataNotif.duration)
    },
    style (notif) {
      if (!notif) return
      if (!notif.backgroundColor) { return { color: 'black' } }
      return { color: notif.backgroundColor }
    }
  }
}
</script>

<style scoped>
.notifications {
  position: absolute;
  z-index: 1;
  
  width: 100%;
  top: 10px;
}

.notification {
  position: relative;

  margin-top: -100px;
  margin-left: auto;
  margin-right: auto;

  width: 95%;
  height: 100%;
  padding: 8px;

  box-shadow: 0px 2px 10px rgba(0, 0, 0, .8);
  background-color: rgb(255, 255, 255);
  color: rgb(0, 0, 0);
  border-radius: 10px;

  /* transition: height 1s ease-in; */
  animation-name: notif-anim;
  animation-duration: 3s;
  animation-fill-mode: forwards;
}

@keyframes notif-anim {
  0% {
    transform: translateY(0);
  }
  10% {
    transform: translateY(100px);
  }
  90% {
    transform: translateY(100px);
  }
  100% {
    transform: translateY(-300px);
  }
}

.appName {
  font-size: 15px;
  font-weight: bold;
}

.appName span {
  font-size: 18px;
  font-weight: bold;
}

.divider {
  height: .5px;
  width: 98%;

  margin-top: 3px;
  margin-bottom: 3px;
  margin-left: auto;
  margin-right: auto;

  background-color: gray;
}

.message-title {
  margin-top: 5px;
  color: rgb(0, 0, 0);
  font-size: 14px;
  font-weight: bold;
}

.message {
  margin-top: 6px;
  color: rgb(58, 58, 58);
  font-size: 14px;
}
</style>
