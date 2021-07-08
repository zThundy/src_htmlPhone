<template>
  <div style="width: 100%; height: 743px;" class="lockscreen" v-bind:style="{ background: 'url(' + this.backgroundURL + ')' }">
    <div class="lockscreen-brightness">
      <InfoBare />

      <div class="immagine">
        <i class="fas fa-lock"></i>
        <!-- <img src="/html/static/img/app_dati/lockscreen.png"> -->
      </div>

      <div v-if="hasUnredMessages" class="messagelist">
        <div v-for="(elem, key) in buildUnreadMessages" v-bind:key="key">
          <span v-if="key < 5" class="messlist">
            <div class="warningMess_icon">
              <i class="fa fa-envelope" :style="{ color: colors[key] }"></i>
            </div>

            <span class="warningMess_content">
              <div class="transmitter">{{ elem.transmitter || elem.authorPhone }}</div>
              <div class="messaggio">{{ formatEmoji(checkAdditionalFormat(elem.message)) }}</div>
            </span>
          </span>
        </div>
      </div>

      <div class='bottom-zone'>
        <div class="rectangle">
          <div v-if="!hasPressed" class="rectangle-inside"></div>
          <div v-else class="rectangle-inside slide"></div>
        </div>
      </div>

    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import InfoBare from './InfoBare'

export default {
  components: { InfoBare },
  data () {
    return {
      unloacked: false,
      hasUnredMessages: false,
      hasPressed: false,
      listaMessaggi: [],
      colors: {}
    }
  },
  computed: {
    ...mapGetters([
      'LangString',
      'UnreadMessagesLength',
      'backgroundURL',
      'messages',
      'unreadMessages',
      'UnreadAziendaMessagesLength',
      'unreadAziendaMessages'
    ]),
    buildUnreadMessages () {
      this.buildColors()
      if (this.UnreadMessagesLength > 5) {
        return this.unreadMessages
      } else if (this.UnreadMessagesLength < 5 && this.UnreadAziendaMessagesLength > 1) {
        return [...this.unreadMessages, ...this.unreadAziendaMessages]
      } else {
        return [...this.unreadMessages, ...this.unreadAziendaMessages]
      }
    }
  },
  methods: {
    ...mapActions([
      'closePhone',
      'setupUnreadMessages',
      'resetUnreadMessages',
      'sendStartupValues'
    ]),
    buildColors () {
      var total = [...this.unreadMessages, ...this.unreadAziendaMessages]
      for (var i in total) {
        if (i < this.UnreadMessagesLength) {
          this.colors[i] = '#019208d2'
        } else {
          this.colors[i] = 'rgb(255, 160, 40)'
        }
      }
    },
    onEnter () {
      if (this.hasPressed) return
      this.hasPressed = true
      setTimeout(() => {
        this.$router.push({ name: 'home' })
        this.$phoneAPI.onplaySound({ sound: 'phoneUnlock.ogg', volume: this.volume || 0.5, loop: false })
      }, 450)
    },
    onBack () {
      this.closePhone()
    },
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
      if (this.$phoneAPI.isLink(message)) {
        return this.LangString('PHONE_IMAGE_MESSAGE_TITLE')
      }
      return message
    }
  },
  created () {
    // this.$phoneAPI.requestInfoOfGroups()
    this.$phoneAPI.requestOfferta()
    this.setupUnreadMessages()
    // this.$phoneAPI.requestMyCovers()
    this.sendStartupValues()
    /*
    for (var key in this.messages) {
      if (this.messages[key].isRead === 0) {
        var string = this.messages[key].message
        if (string !== null && string.length > 20) {
          var index = this.listaMessaggi.length
          this.listaMessaggi[index] = this.messages[key]
          Vue.set(this.listaMessaggi[index], 'message', string.substring(0, 22) + '...')
        } else {
          this.listaMessaggi[this.listaMessaggi.length] = this.messages[key]
        }
      }
    }
    */
    if (this.UnreadMessagesLength > 0) { this.hasUnredMessages = true }
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  beforeDestroy () {
    this.resetUnreadMessages()
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped="true">

/* ####################### */
/* ZONA SOPRA PRE MESSAGGI */
/* ####################### */


.immagine {
  top: 40px;
  position: relative;
  margin-left: auto;
  margin-right: auto;
  text-align: center;
}

.immagine i {
  font-size: 80px;
  color: white;
}


/* ####################### */
/* ZONA SOPRA CON MESSAGGI */
/* ####################### */

.messagelist {
  width: 100%;
  height: 60%;
  margin-top: 65px;
}


.messlist {
  background-color: rgb(224, 224, 224);
  position: relative;
  margin-left: auto;
  margin-right: auto;
  margin-top: 3px;
  /* left: 15px; */
  /* right: 12px; */
  width: 300px;
  /* top: 150px; */
  min-height: 64px;
  /* width: 300px; */
  display: flex;
  padding: 8px;
  border-radius: 5px;
  box-shadow: 0 2px 2px 0 rgb(0 0 0 / 14%), 0 3px 1px -2px rgb(0 0 0 / 20%), 0 1px 5px 0 rgb(0 0 0 / 12%);
}

.messlist .warningMess_icon {
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  height: 42px;
  width: 40px;
  border-radius: 50%;
}

.messlist .warningMess_content {
  line-height: 20px;
  padding-left: 10px;
  background-color: rgb(224, 224, 224);
}

.transmitter {
  padding-top: 4px;
  font-size: 15px;
  color: rgb(0, 0, 0);
  font-weight: bolder;
}

.messaggio {
  padding-top: 0px;
  padding-left: 4px;
  font-weight: bold;
  font-size: 15px;
  color: rgba(34, 34, 34, 0.555);
}

.separatore {
  padding-top: 5px;
}

.warningMess_title {
  font-size: 20px;
}

.warningMess_mess {
  font-size: 16px;
}


/* ##################### */
/* ZONA SOTTO CON SLIDER */
/* ##################### */


.lockscreen {
  background-size: cover !important;
  background-position: center !important;
  
  position: relative;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  display: flex;
  align-content: center;
  justify-content: center;
}

.lockscreen-brightness {
  width: 100%;
  background-color: rgba(0, 0, 0, 0.7);
}

.bottom-zone {
  display: -ms-flexbox;
  display: flex;
  padding: 6px;
  width: 100%;
  bottom: 25px;
  position: absolute;
  -ms-flex-align: end;
  align-items: flex-end;
  -ms-flex-flow: row;
  flex-flow: row;
  -ms-flex-wrap: wrap;
  flex-wrap: wrap;
  /* margin-bottom: 0px; */
  -ms-flex-pack: justify;
  /* justify-content: space-between; */
  transition: all 0.5s ease-in-out;
  /* margin-left: auto; */
  /* margin-right: auto; */
  -ms-flex-pack: center;
  justify-content: center;
}

.slide {
  animation-name: slide;
  animation-duration: 0.5s;
  animation-fill-mode: unset;
}

@keyframes slide {
  from {
    /* padding-left: 0px; */
    transform: translateX(0);
  }
  to {
    /* padding-left: 270px; */
    transform: translateX(191px);
  }
}

.rectangle {
  width: 280px;
  height: 50px;
  background: rgba(255, 255, 255, 0.2);
  border: 4px solid black;
  border-radius: 15px;
}

.rectangle-inside {
  width: 80px;
  height: 100%;
  background: rgba(255, 255, 255, 0.7);
  border-radius: 10px;
}

</style>
