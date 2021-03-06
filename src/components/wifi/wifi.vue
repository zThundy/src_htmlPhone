<template>
  <div class="phone_app">
    <PhoneTitle :title="LangString('APP_WIFI_TITLE')" @back="onBackspace"/>
    <div class='elements'>

      <div class='element' v-for='(elem, key) in retiWifi' v-bind:class="{select: key === currentSelect}" v-bind:key="key">
        <div v-if="elem.toggleDiv == true" class="toggle">
          <div class="elem-label">Attiva / Disattiva Wifi</div>
          <img class="image" v-if="!acceso" src="/html/static/img/app_wifi/toggleoff.png">
          <img class="image" v-if="acceso" src="/html/static/img/app_wifi/toggleon.png">
        </div>

        <div v-if="acceso && elem.toggleDiv != true">
          <div class="elem-label">{{elem.label}} <img class="right-side" src="/html/static/img/app_wifi/wifilocked.png"></div>
        </div>

      </div>
    </div>
  </div>
</template>
<script>
import { mapGetters } from 'vuex'
import PhoneTitle from './../PhoneTitle'

export default {
  components: {
    PhoneTitle
  },
  data () {
    return {
      currentSelect: 0,
      acceso: false
    }
  },
  computed: {
    ...mapGetters(['LangString', 'retiWifi'])
  },
  methods: {
    scrollIntoView: function () {
      this.$nextTick(() => {
        this.$el.querySelector('.select').scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' })
      })
    },
    onBackspace () {
      this.$router.push({ name: 'menu' })
    },
    async onEnter () {
      if (this.currentSelect === 0) {
        this.acceso = !this.acceso

        if (!this.acceso) {
          this.$phoneAPI.connettiAllaRete({shut: true})
        } else {
          this.$phoneAPI.connettiAllaRete({shut: false})
        }
      } else if (this.acceso && this.currentSelect !== 0) {
        var rep = await this.$phoneAPI.getReponseText()
        if (rep.text != null && rep.text === this.retiWifi[this.currentSelect].password) {
          this.$phoneAPI.connettiAllaRete(this.retiWifi[this.currentSelect])
        } else {
          this.$phoneAPI.connettiAllaRete(false)
        }
      }
    },
    onUp () {
      if (!this.acceso) {
        this.currentSelect = 0
      } else {
        this.currentSelect = this.currentSelect === 0 ? 0 : this.currentSelect - 1
      }
      this.scrollIntoView()
    },
    onDown () {
      if (!this.acceso) {
        this.currentSelect = 0
      } else {
        this.currentSelect = this.currentSelect === this.retiWifi.length - 1 ? this.currentSelect : this.currentSelect + 1
      }
      this.scrollIntoView()
    }
  },
  created () {
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
  }
}
</script>

<style scoped>
.screen{
  position: relative;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
}

.title{
  padding-left: 16px;
  height: 34px;
  line-height: 34px;
  font-weight: 700;
  color: rgb(0, 0, 0);
  background-color: rgb(76, 175, 80);
}

.elements{
  height: 5px;
}

.toggle{
  padding-left: 1px;
}

.image{
  position: absolute;
  width: 320px;
  height: 45px;
  top: 90px;
  padding-left: 260px;
}

.element{
  height: 45px;
  width: 100%;
  display: flex;
  position: left;
}

.element.select{
  background-color: rgba(194, 194, 194, 0.411);
}

.elem-label{
  position: left;
  padding-left: 10px;
  font-size: 25px;
}

.elem-right{
  position: absolute;
  height: 30px;
  width: 250px;
  padding-left: 200px;
}

.left-side {
    float: left;
    max-width: 50%;
    max-height: 550px;
    overflow-y: auto;
    height: auto;
    text-align: left;
    user-select: none;
}

.right-side {
    position: absolute;
    left: 65%;
    right: 10%;
    width: 35%;
    max-width: 300%;
    max-height: 550px;
    overflow-y: auto;
    height: auto;
    text-align: left;
    user-select: none;
}

</style>
