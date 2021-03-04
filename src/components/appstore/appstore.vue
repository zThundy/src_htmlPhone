<template>
  <div class="phone_app">
    <PhoneTitle :title="LangString('APP_APPSTORE_TITLE')" :backgroundColor="'rgb(0,0,0,0.1)'" />

    <div class="app_container">
      <!--
      <div class="app_buttons" v-for="(app, key) in downloadableApps" :key="key" :class="{ 'select': currentSelect === key }">

        <img class="app_icon" :src="app.icons">

      </div>
      -->

      <div class="app_buttons">
        <div class="app_button_container" v-for="(but, key) of downloadableApps" :key="but.name" :class="{ 'select': key === currentSelect }">
          <button class="app_button" style="font-weight: 400;" :style="{ backgroundImage: 'url(' + but.icons + ')' }">{{ but.intlName }}</button>
          
          <custom-loading-bar class="app_loading_bar" :start="computedApps[key]" :min="0" :max="100" :identifier="key" :showPerc="true" :duration="4000" @onEnd="onEnd"/>
        </div>
      </div>

    </div>

  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import PhoneTitle from './../PhoneTitle'
import Modal from '@/components/Modal/index.js'

import CustomLoadingBar from '@/components/CustomLoadingBar'

export default {
  name: 'appstore',
  components: { PhoneTitle, CustomLoadingBar },
  data () {
    return {
      currentSelect: -1,
      computedApps: []
    }
  },
  computed: {
    ...mapGetters([
      'downloadableApps',
      'LangString'
    ])
  },
  methods: {
    ...mapActions([
      'setupApps',
      'installApp'
    ]),
    scrollIntoViewIfNeeded () {
      this.$nextTick(() => {
        const elem = this.$el.querySelector('.select')
        if (elem !== null) {
          elem.scrollIntoViewIfNeeded()
        }
      })
    },
    onBackspace () {
      this.$router.push({ name: 'menu' })
    },
    onEnter () {
      if (this.currentSelect === -1) return
      this.computedApps[this.currentSelect] = true
      // qui uso questo trick per aggiornare
      this.currentSelect = this.currentSelect - 1
      this.currentSelect = this.currentSelect + 1
    },
    async onRight () {
      let choix = [
        {id: 1, title: this.LangString('APP_APPSTORE_DOWNLOAD'), icons: 'fa-download'},
        {id: 2, title: this.LangString('CANCEL'), color: 'red', icons: 'fa-undo'}
      ]
      const resp = await Modal.CreateModal({ choix })
      // risposta del menù
      switch (resp.id) {
        case 1:
          break
        case 2:
          break
      }
    },
    onUp () {
      if (this.currentSelect === -1) return
      this.currentSelect = this.currentSelect - 1
      this.scrollIntoViewIfNeeded()
    },
    onDown () {
      if (this.currentSelect === this.downloadableApps.length - 1) return
      this.currentSelect = this.currentSelect + 1
      this.scrollIntoViewIfNeeded()
    },
    onEnd (identifier) {
      this.installApp({ identifier: identifier, app: this.downloadableApps[identifier] })
    }
  },
  created () {
    for (var i in this.downloadableApps) {
      this.computedApps[i] = false
    }

    this.setupApps(this.downloadableApps)

    this.$bus.$on('keyUpArrowRight', this.onRight)

    this.$bus.$on('keyUpBackspace', this.onBackspace)
    this.$bus.$on('keyUpEnter', this.onEnter)

    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpArrowDown', this.onDown)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowRight', this.onRight)

    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpEnter', this.onEnter)

    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpArrowDown', this.onDown)
  }
}
</script>

<style scoped>
.app_container {
  display: flex;

  flex-wrap: wrap;

  align-content: flex-start;
  align-items: flex-start;

  width: 100%;
  height: 100%;
}

.app_buttons {
  display: flex;
  width: 100%;
  height: 93%;

  align-items: flex-start;
  align-content: flex-start;

  margin-left: auto;
  margin-right: auto;

  flex-direction: column;
  overflow-y: auto;
}

.app_button_container {
  width: 100%;
}

.select {
  background-color: rgba(172, 172, 172, 0.425)
}

.app_button {
  position: relative;
  border: none;
  width: 62px;
  height: 80px;
  margin: 10px;

  color: black;
  background-size: 52px 52px;
  background-position: center 5px;
  background-repeat: no-repeat;
  background-color: transparent;

  font-size: 11px;
  padding-top: 52px;
  font-weight: 700;

  text-align: center;
}

.app_loading_bar {
  position: relative;
  bottom: 70%;
  left: 23%;
}

.app_icon {
  width: 100%;
}

.app_name {
  position: relative;
  align-content: center;
}
</style>
