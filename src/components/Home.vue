<template>
  <div class="home" :style="{ background: 'url(' + backgroundURL +')' }">
    <InfoBare style="width: 100%;" />
    <DropdownNotifications :show="showDropdown"/>
    
    <span :style="computeMeteoSection()" class="time">
      <i class="meteo-icon fas fa-sun"></i>
      <current-time class="current-time"></current-time>
    </span>

    <div class='home_buttons'>
      <button v-for="(but, key) of AppsHome" :key="but.name" 
        :class="{ select: key === currentSelect }"
        class="app_buttons"
        :style="{ backgroundImage: 'url(' + but.icons +')' }"
      >
        <span class="notifications-amount" v-if="but.puce !== undefined && but.puce !== 0">{{ but.puce }}</span>
      </button>
        
      <div class="btn_menu_ctn">
        <button :class="{ select: AppsHome.length === currentSelect }" :style="{ backgroundImage: 'url(' + '/html/static/img/icons_app/menu.png' +')' }">
        </button>
      </div>
    </div>

  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import InfoBare from './InfoBare'
import DropdownNotifications from '@/components/DropdownNotifications'
import CurrentTime from './CurrentTime'

export default {
  name: 'homepage',
  components: { InfoBare, DropdownNotifications, CurrentTime },
  data () {
    return {
      currentSelect: 0,
      showDropdown: false
    }
  },
  computed: {
    ...mapGetters(['LangString', 'backgroundURL', 'messages', 'AppsHome'])
  },
  methods: {
    ...mapActions(['closePhone']),
    onLeft () {
      if (this.showDropdown) return
      this.currentSelect = (this.currentSelect + 1) % (this.AppsHome.length + 1)
    },
    onRight () {
      if (this.showDropdown) return
      this.currentSelect = (this.currentSelect + this.AppsHome.length) % (this.AppsHome.length + 1)
    },
    onUp () {
      if (this.showDropdown) return
      this.$router.push({ name: 'menu' })
    },
    onDown () {
      if (this.showDropdown) return
      this.showDropdown = !this.showDropdown
    },
    openApp (app) {
      this.$router.replace({ name: app.routeName })
    },
    onEnter () {
      if (this.showDropdown) return
      this.openApp(this.AppsHome[this.currentSelect] || { routeName: 'menu' })
    },
    onBack () {
      if (this.showDropdown) {
        this.showDropdown = false
        return
      }
      this.closePhone()
    },
    computeMeteoSection () {
      if (this.showDropdown) {
        return {
          opacity: '0'
        }
      }
    }
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
.time {
  position: absolute;
  top: 50px;
  /* font-size: 40px; */
  color: white;
  transition: all 1.5s ease;
}

.time .current-time {
  font-size: 70px;
}

.time .meteo-icon {
  font-size: 50px;
  margin-right: 15px;
  color: yellow;
}

.home {
  background-size: cover !important;
  background-position: center !important;
  
  width: 100%;
  height: 100%;
  
  position: relative;
  left: 0;
  top: 0;
  display: flex;
  align-content: center;
  justify-content: center;
  color: gray;

  animation-name: blur-animation;
  animation-duration: 0.2s;
  animation-fill-mode: forwards;
  animation-timing-function: ease-in;
}

@keyframes blur-animation {
  from {filter: blur(3px);}
  to {filter: blur(0);}
}

.home_buttons {
  display: flex;
  
  height: 95px;
  width: 90%;
  bottom: 5px;
  position: absolute;
  align-items: flex-end;
  flex-flow: row;
  flex-wrap: wrap;
  margin-bottom: 10px;
  justify-content: space-between;

  background-color: rgba(128, 128, 128, 0.5);
  border-radius: 20px;

  transition: all 0.5s ease-in-out;
}

.home_buttons .app_buttons {
  top: -8px;
  margin-left: 10px;
  margin-right: 10px;
}

button {
  position: relative;
  margin: 0px;
  border: none;
  width: 80px;
  height: 76px;
  color: white;

  background-size: 64px 64px;
  background-position: center 6px;
  background-repeat: no-repeat;
  background-color: transparent;

  font-size: 14px;
  font-weight: 700;

  text-shadow: -1px 0 0 rgba(0, 0, 0, 0.8), 1px 0 0 rgba(0, 0, 0, 0.8), 0 -1px 0 rgba(0, 0, 0, 0.8), 0 1px 0 rgba(0, 0, 0, 0.8);
  text-align: center;
}

button .notifications-amount {
  position: absolute;
  display: block;
  background-color: #ff3939;
  font-size: 14px;
  width: 26px;
  height: 26px;
  top: -5px;
  left: 51px;
  line-height: 28px;
  text-align: center;
  border-radius: 50%;
  font-weight: 400;
  bottom: 32px;
  right: 12px;
  
  bottom: 32px;
  right: 12px;
}

button.select {
  background-color: rgba(255, 255, 255, 0.2);
  border-radius: 22%;
}

.btn_menu_ctn {
  position: absolute;
  width: 100%;
  display: flex;
  height: 84px;
  justify-content: center;
  align-content: center;
  border-radius: 24px;
}
</style>
