<template>
  <div class="phone_app">
    <PhoneTitle :title="LangString('APP_DATI_TITLE')" @back="onBackspace" :backgroundColor="'rgb(120, 205, 255)'" />

    <div class='elements'>
      <div class="toast">
        <custom-toast @hide="toastHide" :duration="2000" ref="updating">
          <md-activity-indicator
            :size="20"
            :text-size="16"
            color="white"
            text-color="white"
          >Aggiornamento...
          </md-activity-indicator>
        </custom-toast>

        <custom-toast ref="success" :content="'Riuscito'">
          <md-icon name="right" size="20px" color="lime"></md-icon>
          <div style="font-size: 17px; padding-left: 2px;">Riuscito</div>
        </custom-toast>
      </div>

      <div v-for='(elem, key) in datiInfo' :key="key">
        <md-progress
          :style="posizioni[key]"
          :size="130"
          :value="(elem.current/elem.max)"
          :width="5"
          :linecap="'round'"
          :transition="true"
          :rotate="90"
          :color="'rgb(100, 185, 255)'"
        >
          <!-- <md-icon :style="Math.floor(elem.current/elem.max) == 0 ? { color: 'rgb(255, 185, 100)' } : { color: 'rgb(100, 185, 255)' }" class="md-notice-demo-icon md-notice-demo-icon-left" :name="elem.icon"></md-icon> -->
          <md-icon style="color: rgb(100, 185, 255);" class="md-notice-demo-icon md-notice-demo-icon-left" :name="elem.icon"></md-icon>
        </md-progress>
      </div>

      <div style="z-index: -1; padding-top: 458px;">
        <div v-for='(elem, key) in datiInfo' :key="key + 'secondo'">
          <div class="md-example-child md-example-child-notice-bar md-example-child-notice-bar-7">
            <md-notice-bar class="noticeBars" scrollable>
              <md-icon style="color: rgb(100, 185, 255);" slot="left" class="md-notice-demo-icon md-notice-demo-icon-left" :name="elem.icon"></md-icon>
              {{elem.current}}/{{elem.max}} {{elem.suffix}}
            </md-notice-bar>
          </div>

        </div>
      </div>

    </div>
  </div>
</template>

<script>
import { mapGetters, mapMutations } from 'vuex'
import PhoneTitle from './../PhoneTitle'

import { NoticeBar, Progress, Icon, ActivityIndicator } from 'mand-mobile'
import 'mand-mobile/lib/mand-mobile.css'

import CustomToast from '@/components/CustomToast'
import Modal from '@/components/Modal/index.js'

export default {
  name: 'dati',
  components: {
    PhoneTitle,
    [Progress.name]: Progress,
    [NoticeBar.name]: NoticeBar,
    [Icon.name]: Icon,
    CustomToast,
    // [Toast.component.name]: Toast.component,
    [ActivityIndicator.name]: ActivityIndicator
  },
  data () {
    return {
      disableBackspace: false,
      posizioni: [{
        'left': '10px',
        'padding-top': '130px',
        position: 'absolute'
      }, {
        'right': '10px',
        'padding-top': '130px',
        position: 'absolute'
      }, {
        'right': '100px',
        'padding-top': '230px',
        position: 'absolute'
      }]
    }
  },
  computed: {
    ...mapGetters(['LangString', 'datiInfo', 'segnale'])
  },
  methods: {
    ...mapMutations(['SET_DATI_INFO']),
    onBackspace () {
      if (this.disableBackspace) return
      this.$router.push({ name: 'menu' })
    },
    async onRight () {
      if (this.disableBackspace) return
      this.disableBackspace = true
      let scelte = [
        {id: 1, title: this.LangString('APP_DATI_REFRESH'), icons: 'fa-plus'},
        {id: 2, title: this.LangString('CANCEL'), color: 'red', icons: 'fa-undo'}
      ]
      const resp = await Modal.CreateModal({ scelte })
      // risposta del menù
      switch (resp.id) {
        case 1:
          this.$refs.updating.show()
          break
        case 2:
          this.disableBackspace = false
          break
      }
      // qui controllo se la persona ha premuto solo la backspace per
      // chiudere il modal aperto
      if (resp.title === 'cancel') {
        this.disableBackspace = false
      }
    },
    toastHide () {
      this.$refs.success.show()
      this.$phoneAPI.requestOfferta()
      // questo è il timeout che nasconde
      // il toast "successo"
      setTimeout(() => {
        this.disableBackspace = false
        this.$refs.success.hide()
      }, 1500)
    }
  },
  created () {
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
  }
}
</script>

<style scoped>
.elements {
  height: calc(200% - 34px);
  overflow-y: auto;
}

.toast {
  position: absolute;
  width: 100%;
  height: 62%;
}

.noticeBars {
  z-index: 0;
  color: rgb(100, 175, 255);
  background-color: rgba(100, 185, 255, 0.4);
}

/*
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
  color: white;
  background-color: rgb(76, 175, 80);
}

.element{
  height: 170px;
  width: 100%;
  line-height: 56px;
  display: flex;
  position: middle;
}

.element.select{
  background-color: rgb(255, 255, 255);
}

.elem-label{
  padding-left: 120px;
  flex: 1;
  font-size: 22px;
  position: center;
  white-space: nowrap;
  font-weight: 100;
  font-size: 15px;
}

.elem-right{
  text-align: center;
  width: 90px;
  font-size: 18px;
  font-weight: 700;
  font-weight: 100;
  font-size: 15px;
  padding-right: 6px;
}
*/

/* CERCHI INDICATORI */

/*
.flex-wrapper {
  display: flex;
  flex-flow: row nowrap;
}

.single-chart {
  width: 85%;
  justify-content: space-around;
  position: middle;
}

.circular-chart {
  display: block;
  margin: 10px auto;
  max-width: 80%;
  max-height: 250px;
  padding-left: 60px;
  position: middle;
}

.circle-bg {
  fill: none;
  stroke: #eee;
  stroke-width: 3.8;
}

.circle {
  fill: none;
  stroke-width: 2.8;
  stroke-linecap: round;
  animation: progress 1s ease-out forwards;
}

@keyframes progress {
  0% {
    stroke-dasharray: 0 100;
  }
}

.circular-chart.orange .circle {
  stroke: #ff9f00;
}

.circular-chart.green .circle {
  stroke: #4CC790;
}

.percentage {
  fill: rgb(0, 0, 0);
  font-family: sans-serif;
  font-size: 0.40em;
  text-anchor: middle;
}

.label-sotto {
  fill: rgb(0, 0, 0);
  font-family: sans-serif;
  word-spacing: 0.1em;
  font-size: 0.22em;
  text-anchor: middle;
  position: absolute;
}
*/

</style>
