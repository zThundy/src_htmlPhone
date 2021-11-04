<template>
  <div style="width: 100%; height: 100%;" class="phone_app">
    <!-- <PhoneTitle :backgroundColor="'rgba(0, 0, 0, 0)'" :title="currentScreen.title" :class="{ gradient_bg: currentScreenIndex != 2 }" :back="quit"/> -->
    <PhoneTitle class="decor-border" :backgroundColor="'white'" :title="currentScreen.title" :back="quit"/>
    <div class="phone-title-icon">
      <i class="fa fa-instagram"></i>
    </div>
    
    <div style="overflow: hidden;" class="phone_content">
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
  border-top: 1px solid rgb(230, 230, 230);
  height: 70px;
  display: flex;
  width: 100%;
}

.decor-border {
  border-bottom: 1px solid black;
}

.instagram-menu-item {
  flex-grow: 1;
  flex-basis: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  color: rgb(180, 180, 180);
  font-size: 20px;
}

.instagram-menu-item.select {
  color: rgb(0, 0, 0);
}

.phone-title-icon {
  /* font-size: 31px; */
  position: absolute;
  margin-top: 37px;
  /* margin-left: 280px; */
  /* float: right; */
  width: 100%;
  /* margin-right: 50px; */
  color: rgba(0, 0, 0, 0.9);
}

.phone-title-icon i {
  font-size: 40px;
  float: right;
  margin-right: 20px;
}
</style>
