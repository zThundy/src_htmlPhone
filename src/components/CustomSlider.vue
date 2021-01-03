<template>
  <div class="custom-slider">
    <div class="custom-slider-bar" :style="barStyle"></div>

    <div class="custom-slider-handle" :style="{ 'left': lowerHandlePosition + '%' }">

      <!-- <span class="sliderBall" @mousedown="$_startLowerDrag" @touchstart="$_startLowerDrag"></span> -->
      <span class="sliderBall"></span>
    </div>

  </div>
</template>

<script>

export default {
  name: 'custom-slider',
  props: {
    value: {
      type: [Array, Number],
      default: 0
    },
    min: {
      type: Number,
      default: 0
    },
    max: {
      type: Number,
      default: 100
    },
    step: {
      type: Number,
      default: 1
    },
    format: {
      type: Function,
      default (val) {
        return val
      }
    }
  },
  data () {
    return {
      isDragging: false,
      isDragingUpper: false,
      values: [this.min, this.max],
      startDragMousePos: 0,
      startVal: 0
    }
  },
  watch: {
    value: {
      immediate: true,
      handler (val) {
        if ((Array.isArray(val) && (val[0] !== this.values[0] || val[1] !== this.values[1])) || val !== this.values[0]) {
          this.$_updateValue(val)
        }
      }
    }
  },
  computed: {
    lowerHandlePosition () {
      return ((this.values[0] - this.min) / (this.max - this.min) * 100) - 5
    },
    barStyle () {
      const {values, min, max} = this
      return {
        width: (values[0] - min) / (max - min) * 100 + '%'
      }
    }
  },
  methods: {
    $_updateValue (newVal) {
      let newValues = []
      if (Array.isArray(newVal)) {
        newValues = [newVal[0], newVal[1]]
      } else {
        newValues[0] = newVal
      }
      if (typeof newValues[0] !== 'number') {
        newValues[0] = this.values[0]
      } else {
        newValues[0] = Math.round((newValues[0] - this.min) / this.step) * this.step + this.min
      }
      if (typeof newValues[1] !== 'number') {
        newValues[1] = this.values[1]
      } else {
        newValues[1] = Math.round((newValues[1] - this.min) / this.step) * this.step + this.min
      }
      // value boundary adjust
      if (newValues[0] < this.min) {
        newValues[0] = this.min
      }
      if (newValues[1] > this.max) {
        newValues[1] = this.max
      }
      if (newValues[0] > newValues[1]) {
        if (newValues[0] === this.values[0]) {
          newValues[1] = newValues[0]
        } else {
          newValues[0] = newValues[1]
        }
      }
      if (this.values[0] === newValues[0] && this.values[1] === newValues[1]) {
        return
      }
      this.values = newValues
      this.$emit('input', this.values[0])
    }
    // $_startLowerDrag (e) {
    //   e.preventDefault()
    //   e.stopPropagation()
    //   e = e.changedTouches ? e.changedTouches[0] : e
    //   this.startDragMousePos = e.pageX
    //   this.startVal = this.values[0]
    //   this.isDragingUpper = false
    //   this.isDragging = true
    //   window.addEventListener('mousemove', this.$_onDrag)
    //   window.addEventListener('touchmove', this.$_onDrag)
    //   window.addEventListener('mouseup', this.$_onUp)
    //   window.addEventListener('touchend', this.$_onUp)
    // },
    // $_startUpperDrag (e) {
    //   e.preventDefault()
    //   e.stopPropagation()
    //   e = e.changedTouches ? e.changedTouches[0] : e
    //   this.startDragMousePos = e.pageX
    //   this.startVal = this.values[1]
    //   this.isDragingUpper = true
    //   this.isDragging = true
    //   window.addEventListener('mousemove', this.$_onDrag)
    //   window.addEventListener('touchmove', this.$_onDrag)
    //   window.addEventListener('mouseup', this.$_onUp)
    //   window.addEventListener('touchend', this.$_onUp)
    // },
    // $_onDrag (e) {
    //   e.preventDefault()
    //   e.stopPropagation()
    //   if (!this.isDragging) {
    //     return
    //   }
    //   e = e.changedTouches ? e.changedTouches[0] : e
    //   window.requestAnimationFrame(() => {
    //     let diff = (e.pageX - this.startDragMousePos) / this.$el.offsetWidth * (this.max - this.min)
    //     let nextVal = this.startVal + diff
    //     if (this.isDragging) {
    //       if (this.isDragingUpper) {
    //         this.$_updateValue([null, nextVal])
    //       } else {
    //         this.$_updateValue([nextVal, null])
    //       }
    //     }
    //   })
    // },
    // $_onUp (e) {
    //   e.preventDefault()
    //   e.stopPropagation()
    //   this.$_stopDrag()
    // },
    // $_stopDrag () {
    //   this.isDragging = false
    //   this.isDragingUpper = false
    //   window.removeEventListener('mousemove', this.$_onDrag)
    //   window.removeEventListener('touchmove', this.$_onDrag)
    //   window.removeEventListener('mouseup', this.$_onUp)
    //   window.removeEventListener('touchend', this.$_onUp)
    // }
  }
}
</script>

<style lang="css">
.custom-slider {
  position: relative;
  width: 80%;
  height: 60px;

  border-radius: 5px;

  margin-left: auto;
  margin-right: auto;
}

.custom-slider::before {
  content: '';
  position: absolute;

  top: 28px;
  left: 0;
  right: 0;
  height: 3px;

  border-radius: 2px;
  background-color: rgb(230, 230, 230);
}

.custom-slider-bar {
  position: absolute;
  left: 0;
  top: 28px;
  height: 3px;
  background-color: rgb(94, 177, 255);
  
  border-radius: 2px;
  z-index: 5;
}

.custom-slider-handle {
  position: absolute;

  top: 19px;

  margin-left: auto;
  margin-right: auto;

  z-index: 15;
  overflow: visible;
}

.custom-slider-handle::after {
  color: white;
  position: absolute;
  pointer-events: none;
  opacity: 0;
  visibility: hidden;
  z-index: 15;

  font-size: 10px;
  line-height: 3;
  /* padding: 8px 16px; */
  border-radius: 50%;
  background-color: rgba(0, 0, 0, 0.39);

  white-space: nowrap;
  left: 50%;
  bottom: 100%;
  margin-bottom: 20px;
  transform: translateX(-40%);
}

.custom-slider-handle:active::after {
  opacity: 1;
  visibility: visible;
}

.custom-slider-handle.is-higher {
  z-index: 20;
}

.sliderBall {
  display: block;
  cursor: pointer;

  width: 21px;
  height: 21px;

  background-color: white;
  border-radius: 50%;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.4);
  transition: transform 200ms;
}
</style>
