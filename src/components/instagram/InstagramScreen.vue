<template>
  <div class="phone_app">
    <PhoneTitle :backgroundColor="'rgba(0, 0, 0, 0)'" :title="currentScreen.title" :class="{ gradient_bg: currentScreenIndex != 2 }" :back="quit"/>
    
    <div class="phone_content">
      <component :is="currentScreen.component"/>
    </div>

    <div class="instagram-menu">
      <div v-for="(s, i) in screen" :key="i" class="instagram-menu-item" :class="{ select: i === currentScreenIndex }" @click.stop="openMenu(i)">
        <i class="fa" :class="s.icon" @click.stop="openMenu(i)"></i>
      </div>
    </div>

  </div>

</template>

<script>
import PhoneTitle from './../PhoneTitle'
import InstagramView from './InstagramView'
import InstagramPost from './InstagramPost'
import InstagramAccount from './InstagramAccount'
import InstagramFiltri from './InstagramFiltri'
import { mapGetters } from 'vuex'

export default {
  components: { PhoneTitle },
  data () {
    return {
      currentScreenIndex: 0
    }
  },
  computed: {
    ...mapGetters(['LangString']),
    screen () {
      return [
        {
          title: this.LangString('APP_INSTAGRAM_SHOW_POSTS_TITLE'),
          component: InstagramView,
          icon: 'fa-instagram'
        },
        {
          title: this.LangString('APP_INSTAGRAM_NEW_POST'),
          component: InstagramPost,
          icon: 'fa-camera'
        },
        {
          title: this.LangString('APP_INSTAGRAM_ACCOUNT'),
          component: InstagramAccount,
          icon: 'fa-user'
        },
        {
          title: this.LangString('APP_INSTAGRAM_EDIT_PICTURE'),
          component: InstagramFiltri,
          icon: 'fa-filter'
        }
      ]
    },
    currentScreen () {
      return this.screen[this.currentScreenIndex]
    }
  },
  watch: {
  },
  methods: {
    onLeft () {
      if (this.currentScreenIndex === 3) return
      this.currentScreenIndex = Math.max(0, this.currentScreenIndex - 1)
    },
    onRight () {
      if (this.currentScreenIndex === 2) return
      this.currentScreenIndex = Math.min(this.screen.length - 1, this.currentScreenIndex + 1)
    },
    home () {
      this.currentScreenIndex = 0
    },
    pagina () {
      this.currentScreenIndex = 3
    },
    openMenu (index) {
      if (this.currentScreenIndex === 2) return
      this.currentScreenIndex = index
    },
    quit () {
      if (this.currentScreenIndex === 0) {
        this.$router.push({ name: 'menu' })
      } else {
        this.currentScreenIndex = 0
      }
    }
  },
  created () {
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('instagramHome', this.home)
    this.$bus.$on('instagramScegliFiltri', this.pagina)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('instagramHome', this.home)
    this.$bus.$off('instagramScegliFiltri', this.pagina)
  }
}
</script>

<style scoped>
/* ########################### */
/* TEST ANIMAZIONI SLIDER MENU */
/* ########################### */

.slide-leave-active,
.slide-enter-active {
  transition: 1s;
}
.slide-enter {
  transform: translate(100%, 0);
}
.slide-leave-to {
  transform: translate(-100%, 0);
}

.img-slider{
  overflow: hidden;
  position: relative;
}

.img-slider img {
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
  right:0;
}

/* ######################## */
/* CSS IN SE DEL MENU SOTTO */
/* ######################## */

.instagram-menu {
  border-top: 1px solid rgb(250, 108, 238);
  height: 56px;
  display: flex;
  width: 100%;
}

.dadel {
  color: rgba(248, 99, 218, 0.5);
}

.instagram-menu-item {
  flex-grow: 1;
  flex-basis: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  color: rgb(250, 108, 238);
}

.instagram-menu-item.select {
  color: #ff009d;
}

.instagram-menu-item:hover {
  color: #ff009d;
}

.gradient_bg {
  background: -moz-linear-gradient(45deg, #f09433 0%, #e6683c 25%, #dc2743 50%, #cc2366 75%, #bc1888 100%); 
  background: -webkit-linear-gradient(45deg, #f09433 0%,#e6683c 25%,#dc2743 50%,#cc2366 75%,#bc1888 100%); 
  background: linear-gradient(45deg, #f09433 0%,#e6683c 25%,#dc2743 50%,#cc2366 75%,#bc1888 100%); 
  filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#f09433', endColorstr='#bc1888',GradientType=1 );
}
</style>
