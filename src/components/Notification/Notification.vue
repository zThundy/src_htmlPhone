<template>
  <div v-if="show === true && tempoHide === false">

    <div class="notifications">
      <div v-for='notif in list' :key="notif.id" class="notification">

        <div class="appName" :style="style(notif)">
          <i v-if="notif.icon" class="fa" :class="'fa-' + notif.icon"/>
          <span>{{ notif.appName }}</span>
        </div>

        <div v-if="notif.title" class="message" style="font-weight: bold">{{ notif.title }}</div>
        <div v-if="notif.message" class="message">{{ notif.message }}</div>

      </div>
    </div>

  </div>
</template>

<script>
import events from './events'
import { Howl } from 'howler'

import { mapGetters } from 'vuex'

export default {
  data () {
    return {
      currentId: 0,
      list: [],
      audio: null
    }
  },
  mounted () {
    events.$on('add', this.addItem)
  },
  computed: {
    ...mapGetters(['show', 'tempoHide'])
  },
  methods: {
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
        this.list.push(dataNotif)
        window.setTimeout(() => { this.destroy(dataNotif.id) }, dataNotif.duration)
      }
      if (event.sound !== null && event.sound !== undefined) {
        var path = '/html/static/sound/' + event.sound
        this.audio = new Howl({
          src: path,
          onend () {
            // ascolto quando l'audio termina e via
            // console.log('audio ended')
            this.audio = null
          },
          onload () {
            // console.log('audio loaded')
          }
        })
        // qui controllo se viene passato il volume.
        // se si lo imposto al valore, altrimenti lo metto a 0.5
        // console.log('event.volume dentro notification', event.volume)
        if (event.volume) {
          this.audio.volume(Number(event.volume))
        } else {
          this.audio.volume(0.5)
        }
        this.audio.play()
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
  
  top: 12px;
  width: 100%;
}

.notification {
  margin-top: 3px;
  margin-left: auto;
  margin-right: auto;

  width: 95%;
  padding: 8px;

  background-color: rgb(255, 255, 255);
  color: rgb(0, 0, 0);
  border-radius: 10px;
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

.message {
  color: rgb(0, 0, 0);
  font-size: 14px;
}
</style>
