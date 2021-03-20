<template>
  <div v-if="show === true && tempoHide === false">

    <div class="notifications">
      <div v-for='notif in list' :key="notif.id" class="notification">

        <div class="appName" :style="style(notif)">
          <i v-if="notif.icon" class="fa" :class="'fa-' + notif.icon"/>
          <span>{{ notif.appName }}</span>
        </div>

        <div class="divider"></div>

        <div v-if="notif.title" class="message-title" style="font-weight: bold">{{ formatEmoji(notif.title) }}</div>
        <div v-if="notif.message" class="message">{{ formatEmoji(notif.message) }}</div>

      </div>
    </div>

  </div>
</template>

<script>
import events from './events'
import { Howl } from 'howler'

import { mapGetters } from 'vuex'

export default {
  components: { },
  data () {
    return {
      currentId: 0,
      list: [],
      soundList: {}
    }
  },
  mounted () {
    events.$on('add', this.addItem)
  },
  computed: {
    ...mapGetters(['show', 'tempoHide', 'volume'])
  },
  methods: {
    formatEmoji (message) {
      return this.$phoneAPI.convertEmoji(message)
    },
    async addItem (event = {}) {
      // console.log(JSON.stringify(event))
      // if (event.hidden) {
      //   var path = '/html/static/sound/' + event.sound
      //   var audio = new Howl({ src: path })
      //   if (event.volume !== undefined || event.volume !== null) {
      //     audio.volume(Number(event.volume))
      //   } else {
      //     audio.volume(0.5)
      //   }
      //   audio.play()
      //   return
      // }
      const dataNotif = { ...event, id: this.currentId++, duration: parseInt(event.duration) || 3000 }
      // dopo essermi buildato i valori li riproduco
      if (!event.hidden) {
        // ho rimosso dataNotif.duration anche se lo prendo comunque
        this.list.push(dataNotif)
        window.setTimeout(() => {
          this.destroy(dataNotif.id)
        }, dataNotif.duration)
      }
      if (event.sound) {
        var path = '/html/static/sound/' + event.sound
        if (event.sound === undefined || event.sound === null) return
        if (this.soundList[event.sound] !== undefined) {
          this.soundList[event.sound].volume = Number(this.volume)
        } else {
          this.soundList[event.sound] = new Howl({
            src: path,
            volume: this.volume
            // onend: function () {
            //   if (this.soundList[event.sound]) {
            //     delete this.soundList[event.sound]
            //   }
            // }
          })
          this.soundList[event.sound].play()
          this.soundList[event.sound].on('end', () => {
            // console.log('deleted', event.sound)
            // console.log('deleted', this.soundList[event.sound])
            delete this.soundList[event.sound]
            // console.log('deleted', this.soundList[event.sound])
          })
        }
      }
    },
    style (notif) {
      if (!notif.backgroundColor) {
        return {
          color: 'black'
        }
      }
      return {
        color: notif.backgroundColor
      }
    },
    destroy (id) {
      this.list = this.list.filter(n => n.id !== id)
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

.title {
  color: rgb(0, 0, 0);
  font-size: 16px;
  font-weight: bold;

  align-content: flex-start;
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
}

.message {
  margin-top: 6px;
  color: rgb(58, 58, 58);
  font-size: 14px;
}
</style>
