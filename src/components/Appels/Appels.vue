<template>
   <div class="phone_app">
    <PhoneTitle :backgroundColor="'rgb(78, 144, 61)'" :title="LangString('APP_PHONE_TITLE')" v-on:back="onBackspace" />

    <div class="subMenu">
      <div class="subMenu-elem" v-for="(Comp, i) of subMenu" :key="i" :class="{ selected: currentMenuIndex === i }">
        <span class="subMenu-name">{{ Comp.name }}</span>
        <span class="subMenu-underline"></span>
      </div>
    </div>
    
    <div class="content">
      <component :is="subMenu[currentMenuIndex].Comp" />
    </div>
    
    <div class="email-write-dot">
      <img src="/html/static/img/icons_app/phone_digits.png" class="email-write-icon"/>
    </div>
   </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

import PhoneTitle from './../PhoneTitle'
import AppelsFavoris from './AppelsFavoris'
import AppelsContacts from './AppelsContacts'
import AppelsRecents from './AppelsRecents'
import AppelsSegreteria from './AppelsSegreteria'
import TransitionPage from '@/components/TransitionPage'

export default {
  components: { PhoneTitle, TransitionPage },
  data () {
    return {
      currentMenuIndex: 1
    }
  },
  computed: {
    ...mapGetters(['LangString', 'themeColor', 'ignoreControls']),
    ...mapActions(['updateIgnoredControls']),
    subMenu () {
      return [{
        Comp: AppelsFavoris,
        name: this.LangString('APP_PHONE_MENU_FAVORITES')
      }, {
        Comp: AppelsRecents,
        name: this.LangString('APP_PHONE_MENU_RECENTS')
      }, {
        Comp: AppelsContacts,
        name: this.LangString('APP_PHONE_MENU_CONTACTS')
      }, {
        Comp: AppelsSegreteria,
        name: this.LangString('APP_PHONE_MENU_SECRETARIAT')
      }]
    }
  },
  methods: {
    getColorItem (index) {
      if (this.currentMenuIndex === index) {
        return {
          color: this.themeColor
        }
      }
      return {}
    },
    swapMenu (index) {
      this.currentMenuIndex = index
    },
    onLeft () {
      if (this.ignoreControls) return
      this.currentMenuIndex = Math.max(this.currentMenuIndex - 1, 0)
    },
    onRight () {
      if (this.ignoreControls) return
      this.currentMenuIndex = Math.min(this.currentMenuIndex + 1, this.subMenu.length - 1)
    },
    onBackspace: function () {
      if (this.ignoreControls === true) return
      this.$router.push({ name: 'menu' })
    }
  },

  created () {
    this.$bus.$on('keyUpBackspace', this.onBackspace)
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
  }
}
</script>

<style scoped>
.screen {
  position: relative;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
}

.title {
  padding-left: 16px;
  height: 34px;
  line-height: 34px;
  font-weight: 700;
  color: white;
  background-color: #2c3e50;
}

.content {
  height: calc(100% - 68px);
  overflow-y: auto;
}

.subMenu {
  position: relative;
  display: flex;
  height: 40px;
  margin-left: 8px;
  margin-right: 8px;
}

/*
.subMenu-icon {
  margin-top: 8px;
  font-size: 22px;
  line-height: 22px;
  height: 22px;
}
*/

.subMenu-underline {
  display: block;
  border-bottom: 1px solid rgba(0, 0, 0, 0.1);
  margin-top: 20px;
}

.subMenu-name {
  display: block;
  font-size: 15px;
  height: 10px;
  margin-top: 10px;
}

.subMenu-elem {
  width: 100%;
  text-align: center;

  display: flex;
  color: rgba(0, 0, 0, 0.3);
  flex-direction: column;
  /* margin-left: 5px; */
  /* margin-right: 5px; */
}

.subMenu-elem.selected {
  color: rgb(13, 158, 0);
  border-bottom: 1px solid rgb(13, 158, 0);
}

.email-write-dot {
  position: fixed;

  bottom: 20%;
  right: 30%;

  box-shadow: 0 0 10px rgba(0, 0, 0, 0.6);
  /* box-shadow: 0 12px 10px -10px black; */
  border-radius: 50%;
}

.email-write-dot .email-write-icon {
  color: white;

  width: 60px;
  height: 60px;

  display: flex;
  justify-content: center;
}
</style>
