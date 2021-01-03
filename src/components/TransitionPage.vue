<template>
  <!--
  <swiper page-transition="fade">
      <slot/>
  </swiper>
  
  <transition :name="transitionName" :mode="transitionMode">
    <slot/>
  </transition>

  <div v-if="isChanging">
    <router-view class="transition"/>
  </div>
  -->

  <swiper
    :page-transition="pageTransition"
    @beforeChange="beforeChange"
    @afterChange="afterChange"
  >
    <slot
      :index="index"
    />
  </swiper>
</template>

<script>
import { Swiper, SwiperItem } from 'vue-h5-swiper'

export default {
  name: `TransitionPage`,
  components: { Swiper, SwiperItem },
  data () {
    return {
      pageTransition: 'cover',
      index: -1
    }
  },
  props: {
    isChanging: {
      type: Boolean,
      default: false
    }
  },

  methods: {
    // beforeChange (activeIndex, oldIndex) {
    //   console.log(`before-change: ${activeIndex}, ${oldIndex}`)
    // },
    // afterChange (activeIndex, oldIndex) {
    //   console.log(`after-change: ${activeIndex}, ${oldIndex}`)
    // }
  },

  created () {
    // this.$router.beforeEach((to, from, next) => {
    //   if (this.isChanging) {
    //     next()
    //   }
    // })
  }
}
</script>

<style lang="css">
.transition {
  position: absolute;

  height: 100%;

  animation-name: transitionApp;
  animation-duration: 0.5s;
  animation-fill-mode: forwards;
}

@keyframes transitionApp {
  from {
    left: 100%;
  }
  to {
    left: 0%;
  }
}
</style>
