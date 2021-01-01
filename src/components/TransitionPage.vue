<template>
  <!--
  <swiper page-transition="fade">
      <slot/>
  </swiper>
  
  <transition :name="transitionName" :mode="transitionMode">
    <slot/>
  </transition>
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

  methods: {
    beforeChange (activeIndex, oldIndex) {
      console.log(`before-change: ${activeIndex}, ${oldIndex}`)
    },

    afterChange (activeIndex, oldIndex) {
      console.log(`after-change: ${activeIndex}, ${oldIndex}`)
    }
  },

  created () {
    this.$router.beforeEach((to, from, next) => {
      if ((to.meta !== undefined && to.meta !== null) && (from.meta !== undefined && from.meta !== null)) {
        if (to.meta.depth > from.meta.depth) {
          this.index = to.meta.depth
        }
        if (from.meta.depth > to.meta.depth) {
          this.index = from.meta.depth
        }
      }
      next()
    })
  }
}
</script>

<style lang="scss">
body {
  margin: 0;
}

.app {
  position: relative;
  .operation {
    position: absolute;
    top: 16px;
    left: 400px;
  }
}
</style>
