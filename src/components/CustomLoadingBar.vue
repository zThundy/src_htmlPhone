<template>
  <div class="custom-loading-bar-container">

    <div class="custom-loading-bar" :style="barStyle">
      <div :class="{ 'custom-loading-bar-blue': start }" :style="'width: ' + loadingAmount + '%'"></div>
      <i>{{ loadingAmount }}%</i>
    </div>

  </div>
</template>

<script>

export default {
  name: 'custom-loading-bar',
  props: {
    min: {
      type: Number,
      default: 0
    },
    max: {
      type: Number,
      default: 100
    },
    showPerc: {
      type: Boolean,
      default: false
    },
    start: {
      type: Boolean,
      default: false
    },
    identifier: {
      type: Number,
      default: -1
    },
    duration: {
      type: Number,
      default: 1000
    }
  },
  data () {
    return {
      loadingAmount: 0
    }
  },
  watch: {
    start: {
      immediate: true,
      handler (val) {
        if (this.start) {
          this.startLoading()
        }
      }
    }
  },
  computed: {
    barStyle () {
      return {
        width: ((this.max - this.min) - 30) + '%'
      }
    }
  },
  methods: {
    startLoading () {
      if (this.loadingAmount >= (this.max - this.min)) {
        if (this.identifier === -1) return
        this.$emit('onEnd', this.identifier)
        return
      }
      setTimeout(() => {
        this.loadingAmount = this.loadingAmount + 1
        this.startLoading()
      }, Math.floor(this.duration / 100))
    }
  },
  created () {
    this.loadingAmount = 0
  }
}
</script>

<style lang="css">
.custom-loading-bar {
  position: relative;
  height: 1px;
  background-color: gray;
  /* width: 70%; */
}

.custom-loading-bar-blue {
  position: relative;
  height: 2px;
  background-color: rgb(61, 152, 255);
  /* width: 70%; */
  transition: all 0.4s ease-in-out;
}

</style>
