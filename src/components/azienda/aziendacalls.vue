<template>
  <div class="azienda-calls-general-container">

    <div v-for="(elem, key) in aziendaCalls" :key="key" class="azienda-call-container" :class="{ selected: key === currentSelected }">
      <div class="azienda-call-header-container">
        <div class="azienda-call-icon-container">
          <i class="fa fa-phone" aria-hidden="true"></i>
        </div>
        <div class="azienda-call-message-container">
          <span class="azienda-call-label-style">{{ LangString("APP_AZIENDA_CALLS_NUMBER_LABEL") }}:</span> {{ elem.number }}
        </div>
      </div>
      <div class="azienda-call-divider "></div>
      <div class="azienda-call-body-container">
        <div><span class="azienda-call-label-style">{{ LangString("APP_AZIENDA_CALLS_MESSAGE_LABEL") }}:</span> {{ formatEmoji(elem.message) }}</div>
        <div><span class="azienda-call-label-style">{{ LangString("APP_AZIENDA_CALLS_POSITION_LABEL") }}:</span> {{ elem.coords.x }}, {{ elem.coords.y }}</div>
      </div>
      <div class="azienda-call-footer-container">
        <timeago class="azienda-call-time" :since='elem.time' :auto-update="20"></timeago>
      </div>
    </div>

  </div>
</template>

<script>
import { mapGetters, mapMutations, mapActions } from 'vuex'
import Modal from '@/components/Modal/index.js'

export default {
  name: 'azienda-calls',
  components: {},
  data () {
    return {
      currentSelected: -1
    }
  },
  computed: {
    ...mapGetters(['LangString', 'aziendaIngoreControls', 'aziendaCalls', 'myAziendaInfo'])
  },
  watch: {
  },
  methods: {
    ...mapMutations(['SET_AZIENDA_IGNORE_CONTROLS']),
    ...mapActions(['startCall']),
    formatEmoji (message) {
      return this.$phoneAPI.convertEmoji(message)
    },
    scrollIntoView () {
      this.$nextTick(() => {
        const elem = this.$el.querySelector('.selected')
        if (elem !== null) {
          elem.scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' })
        }
      })
    },
    onUp () {
      if (this.aziendaIngoreControls) return
      if (this.currentSelected === -1) return
      this.currentSelected = this.currentSelected - 1
      this.scrollIntoView()
    },
    onDown () {
      if (this.aziendaIngoreControls) return
      if (this.currentSelected === this.aziendaCalls.length - 1) return
      this.currentSelected = this.currentSelected + 1
      this.scrollIntoView()
    },
    onEnter () {
      if (this.aziendaIngoreControls) return
      this.openMessageOptions(this.aziendaCalls[this.currentSelected])
    },
    onRight () {
      if (this.aziendaIngoreControls) return
      this.openMessageOptions(this.aziendaCalls[this.currentSelected])
    },
    onBack () {
      if (this.aziendaIngoreControls) {
        this.SET_AZIENDA_IGNORE_CONTROLS(false)
      }
    },
    openMessageOptions (data) {
      if (this.aziendaIngoreControls) return
      console.log(JSON.stringify(data))
      try {
        this.SET_AZIENDA_IGNORE_CONTROLS(true)
        let scelte = [
          { id: 'gps', title: this.LangString('APP_MESSAGE_SET_GPS'), icons: 'fa-location-arrow' },
          { id: 'num', title: `${this.LangString('APP_MESSAGE_MESS_NUMBER')} ${data.numero}`, number: data.numero, icons: 'fa-phone' },
          { id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' }
        ]
        Modal.CreateModal({ scelte }).then(resp => {
          if (resp.id === 'gps') {
            this.$phoneAPI.setGPS(data.coords.x, data.coords.y)
          } else if (resp.id === 'num') {
            this.startCall({ numero: resp.number })
          }
          this.SET_AZIENDA_IGNORE_CONTROLS(false)
        })
      } catch (e) { console.log(e) }
    }
  },
  created () {
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpBackspace', this.onBack)
    this.currentSelected = this.aziendaCalls.length - 1
    setTimeout(() => {
      this.scrollIntoView()
    }, 500)
  },
  mounted () {
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.azienda-calls-general-container {
  width: 100%;
  height: 600px;
  overflow: hidden;
  margin-top: 10px;
  border-radius: 30px;
}

.azienda-call-container {
  width: 95%;
  height: auto;

  background-color: rgb(255, 196, 123);
  border-radius: 20px;

  margin-top: 10px;
  margin-left: auto;
  margin-right: auto;
}

.azienda-call-container.selected {
  background-color: rgb(255, 174, 75);
}

/* GENERAL */
.azienda-call-message-container {
  padding-left: 5px;
}

.azienda-call-label-style {
  color: rgb(63, 63, 63);
  font-weight: bold;
}

.azienda-call-divider {
  width: 90%;
  height: 1px;
  border-bottom: 1px grey solid;
  margin-left: auto;
  margin-right: auto;
  margin-top: 5px;
  margin-bottom: 5px;
}

/* HEADER */
.azienda-call-header-container {
  position: relative;
  width: 100%;
  height: 25%;
  display: flex;
  flex-direction: row;
  padding-top: 5px;
  padding-left: 5px;
}

.azienda-call-icon-container {
  background-color: green;
  border-radius: 20px;
  width: 25px;
  height: 25px;
  text-align: center;
}

.azienda-call-icon-container i {
  padding-top: 3px;
  font-size: 15px;
  color: rgb(1, 230, 1);
}

/* BODY */
.azienda-call-body-container {
  width: 100%;
  height: auto;
  padding-left: 5px;
  display: flex;
  flex-direction: column;
}

/* FOOTER */
.azienda-call-footer-container {
  width: 100%;
  height: 15px;
}

.azienda-call-time {
  float: right;
  color: grey;
  font-size: 10px;
  padding-right: 15px;
  /* padding-bottom: 25px; */
}
</style>
