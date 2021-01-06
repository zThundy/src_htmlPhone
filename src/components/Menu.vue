<template>
  <div class="phone_app">
    
    <!-- <div class="white_rectangle" :class="{ 'app_open': openingApp }"></div> -->

    <div :class="{ 'backblur': !isBackspace }" class="background" v-bind:style="{ background: 'url(' + backgroundURL +')' }"></div>
    <InfoBare class="infobare"/>

    <div class="menu">
      
      <div class="menu_content">
      
        <div class='menu_buttons' :class="{ 'down': isBackspace }">
          <button
            style="font-weight: 400;"
            v-for="(but, key) of Apps"
            :key="but.name"
            :class="{ select: key === currentSelect }"
            :style="{ backgroundImage: 'url(' + but.icons + ')' }"
          >
            {{but.intlName}}
            <span class="puce" v-if="but.puce !== undefined && but.puce !== 0">{{ but.puce }}</span>
          </button>
        </div>

      </div>

    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import InfoBare from './InfoBare'

export default {
  components: { InfoBare },
  data: function () {
    return {
      currentSelect: 0,
      nBotonesMenu: 4,
      isBackspace: false
      // openingApp: false
    }
  },
  computed: {
    ...mapGetters(['UnreadMessagesLength', 'backgroundURL', 'Apps'])
  },
  methods: {
    ...mapGetters(['closePhone', 'hasWifi']),
    onLeft () {
      const l = Math.floor(this.currentSelect / this.nBotonesMenu)
      const newS = (this.currentSelect + this.nBotonesMenu - 1) % this.nBotonesMenu + l * this.nBotonesMenu
      this.currentSelect = Math.min(newS, this.Apps.length - 1)
    },
    onRight () {
      const l = Math.floor(this.currentSelect / this.nBotonesMenu)
      let newS = (this.currentSelect + 1) % this.nBotonesMenu + l * this.nBotonesMenu
      if (newS >= this.Apps.length) {
        newS = l * this.nBotonesMenu
      }
      this.currentSelect = newS
    },
    onUp () {
      let newS = this.currentSelect - this.nBotonesMenu
      if (newS < 0) {
        const r = this.currentSelect % this.nBotonesMenu
        newS = Math.floor((this.Apps.length - 1) / this.nBotonesMenu) * this.nBotonesMenu
        this.currentSelect = Math.min(newS + r, this.Apps.length - 1)
      } else {
        this.currentSelect = newS
      }
    },
    onDown () {
      const r = this.currentSelect % this.nBotonesMenu
      let newS = this.currentSelect + this.nBotonesMenu
      if (newS >= this.Apps.length) {
        newS = r
      }
      this.currentSelect = newS
    },
    openApp (app) {
      this.$router.push({ name: app.routeName })
    },
    onEnter () {
      // this.openingApp = true
      // setTimeout(() => {
      //   this.openingApp = false
      // }, 500)
      this.openApp(this.Apps[this.currentSelect])
    },
    onBack () {
      this.isBackspace = true
      setTimeout(() => {
        this.$router.push({ name: 'home' })
      }, 350)
    }
  },
  mounted () {
  },
  created () {
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.menu {
  position: relative;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  padding: 6px 8px;
}

.background {
  top: -6px;
  left: -6px;
  right:-6px;
  bottom: -6px;

  position: absolute;
  background-size: cover !important;
  background-position: center !important;
}

.backblur {
  filter: blur(6px);

  /* animation-name: blackBG; */
  /* animation-duration: 0.4s; */
  /* animation-fill-mode: forwards; */
}

/* @keyframes blackBG { */
/*   from { filter: blur(0px); } */
/*   to { filter: blur(6px); } */
/* } */

.menu_content {
  display: flex;
  flex-direction: column;
}

.menu_buttons {
  margin-top: 20px;
  display: flex;
  width: 100%;
  align-items: flex-start;
  align-content: flex-start;
  /* justify-content: space-around; */

  margin-left: auto;
  margin-right: auto;

  flex-flow: row;
  flex-wrap: wrap;

  transition: all 0.4s ease-in-out;
}

.menu_buttons {
  animation-name: up;
  animation-duration: 0.4s;
  animation-fill-mode: forwards;
  /* transition: all 0.5s ease-in-out; */
}

@keyframes up {
  from {transform: translateY(100vh);}
  to {transform: translateY(0);}
}

.down {
  animation-name: down;
  animation-duration: 0.4s;
  animation-fill-mode: forwards;
  /* transition: all 0.5s ease-in-out; */
}

@keyframes down {
  from {transform: translateY(0);}
  to {transform: translateY(100vh);}
}


button {
  position: relative;
  border: none;
  width: 62px;
  height: 90px;
  margin: 8px;

  color: white;
  background-size: 52px 52px;
  background-position: center 5px;
  background-repeat: no-repeat;
  background-color: transparent;

  font-size: 10px;
  padding-top: 62px;
  font-weight: 700;
  text-shadow: -1px 0 0 rgba(0,0,0, 0.8), 
             1px 0 0 rgba(0,0,0, 0.8),
             0 -1px 0 rgba(0,0,0, 0.8),
             0 1px 0 rgba(0,0,0, 0.8);

  text-align: center;
}

button .puce {
  position: absolute;
  display: block;
  background-color: #ff3939;
  font-size: 12px;
  width: 16px;
  height: 16px;
  top: 0;
  left: 42px;

  line-height: 19px;
  text-align: center;
  border-radius: 50%;
  
  bottom: 32px;
  right: 10px;
}

button.select {
  border-radius: 10px;

  animation-name: changeActiveState;
  animation-duration: 0.5s;
  animation-fill-mode: both;
}

@keyframes changeActiveState {
  from { background-color: rgba(190, 190, 190, 0); }
  to { background-color: rgba(190, 190, 190, 0.466); }
}

/* ///////////// */
/* APP ANIMATION */
/* ///////////// */

/*
.white_rectangle {
  z-index: 999;
  position: absolute;

  width: 0%;
  height: 100%;
  background-color: rgb(255, 255, 255);
}

.app_open {
  position: absolute;
  top: 0;
  right: 0;

  animation-name: openApp;
  animation-duration: 0.5s;
  animation-fill-mode: forwards;
}

@keyframes openApp {
  from {
    width: 0%;
  }
  to {
    width: 100%;
  }
}
*/

</style>
