<template>
  <div style="width: 100%; height: 743px;" class="lockscreen" v-bind:style="{background: 'url(' + this.backgroundURL + ')'}">
    <div class="lockscreen-brightness">
      <InfoBare />

      <div>
        <img class="immagine" src="/html/static/img/app_dati/lockscreen.png">
      </div>

      <div v-if="hasUnredMessages">
        <div v-for="(elem, key) in unreadMessages" v-bind:key="key">

          <div class="separatore"></div>

          <span v-if="key < 4" class="messlist">
            <div class="warningMess_icon">
              <i class="fa fa-envelope"></i>
            </div>

            <span class="warningMess_content">
              <div class="transmitter">{{elem.transmitter}}</div>
              <div v-if="!isSMSImage(elem.message)" class="messaggio">{{elem.message}}</div>
              <div v-else class="messaggio">Immagine</div>
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
      listaMessaggi: []
    }
  },
  computed: {
    ...mapGetters(['IntlString', 'UnreadMessagesLength', 'backgroundURL', 'messages', 'unreadMessages'])
  },
  methods: {
    ...mapActions(['closePhone', 'setupUnreadMessages', 'resetUnreadMessages', 'sendStartupValues']),
    onEnter () {
      if (this.hasPressed) return
      this.hasPressed = true
      this.$phoneAPI.postPlayUnlockSound()
      setTimeout(() => {
        this.$router.push({ name: 'home' })
      }, 450)
    },
    onBack () {
      this.closePhone()
    },
    isSMSImage (mess) {
      var pattern = new RegExp('^(https?:\\/\\/)?' + '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|' + '((\\d{1,3}\\.){3}\\d{1,3}))' + '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*' + '(\\?[;&a-z\\d%_.~+=-]*)?' + '(\\#[-a-z\\d_]*)?$', 'i')
      return !!pattern.test(mess)
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
  width: 210px;
  height: 100px;
  top: 50px;
  padding-left: 110px;
  position: absolute;
}


/* ####################### */
/* ZONA SOPRA CON MESSAGGI */
/* ####################### */


.messlist {
  background-color: rgb(224, 224, 224);
  position: relative;

  margin-left: auto;
  margin-right: auto;

  /* left: 15px; */
  /* right: 12px; */

  width: 300px;
  top: 150px;
  min-height: 64px;
  display: flex;
  padding: 8px;
  border-radius: 8px;
  box-shadow: 0 2px 2px 0 rgba(0,0,0,.14), 0 3px 1px -2px rgba(0,0,0,.2), 0 1px 5px 0 rgba(0,0,0,.12);
}

.messlist .warningMess_icon{
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  height: 42px;
  width: 40px;
  border-radius: 50%;
}

.messlist .warningMess_icon .fa {
  text-align: center;
  color: #019208d2;
}

.messlist .warningMess_content{
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

.bottom-zone{
  display: flex;
  padding: 6px; 
  width: 100%;
  bottom: 25px;
  position: absolute;
  align-items: flex-end;
  flex-flow: row;
  flex-wrap: wrap;
  margin-bottom: 3px;
  justify-content: space-between;
  transition: all 0.5s ease-in-out;
  padding-left: 25px;
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
  background: rgba(201, 201, 201, 0.384);
  border-style: solid;
  border-radius: 15px;
}

.rectangle-inside {
  width: 80px;
  height: 97%;
  background: rgba(223, 223, 223, 0.856);
  border-radius: 10px;
}

</style>
