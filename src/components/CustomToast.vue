<template>
  <div class="custom-toast">
    <md-popup :value="visible" @show="$_onShow" @hide="$_onHide" :hasMask="false" :maskClosable="false">
      <div :class="[ hasMask ? 'custom-toast-content' : 'custom-toast-content-nobg' ]" v-if="$slots.default">
        <slot></slot>
      </div>

      <div :class="[ hasMask ? 'custom-toast-content' : 'custom-toast-content-nobg' ]" v-else>
        <md-icon v-if="icon" :name="icon" size="lg" :svg="iconSvg"/>
        <div class="custom-toast-text" v-if="content" v-text="content"></div>
      </div>
    </md-popup>
  </div>
</template>

<script>
import { Popup, Icon } from 'mand-mobile'
import 'mand-mobile/lib/mand-mobile.css'

export default {
  name: 'custom-toats',
  components: {
    [Popup.name]: Popup,
    [Icon.name]: Icon
  },
  props: {
    icon: {
      type: String,
      default: ''
    },
    iconSvg: {
      type: Boolean,
      default: false
    },
    content: {
      type: [String, Number],
      default: ''
    },
    duration: {
      type: Number,
      default: 0
    },
    hasMask: {
      type: Boolean,
      default: true
    }
  },
  data () {
    return {
      visible: false
    }
  },
  beforeDestroy () {
    if (this.$_timer) {
      clearTimeout(this.$_timer)
    }
  },
  methods: {
    $_onShow () {
      this.$emit('show')
    },
    $_onHide () {
      this.$emit('hide')
    },
    fire () {
      if (this.$_timer) {
        clearTimeout(this.$_timer)
      }
      if (this.visible && this.duration) {
        this.$_timer = setTimeout(() => {
          this.hide()
        }, this.duration)
      }
    },
    show () {
      this.visible = true
      this.fire()
    },
    hide () {
      this.visible = false
    }
  }
}
</script>

<style lang="css">
.custom-toast {
  width: 100%;
  height: 100%;
  position: absolute;
}

.md-popup {
  z-index: 0;
}

.md-icon {
  flex-shrink: 0;
  color: white;
}

.md-icon .custom-toast-text {
  margin-left: 2%;
}

.md-popup {
  top: 50%;
  z-index: inherit;
  position: relative;
}
  
.md-popup-box {
  width: 540px;
  display: flex;
  justify-content: center;
}

.md-popup-mask {
  background: transparent;
}

.custom-toast-content {
  display: inline-flex;
  align-items: center;
  max-width: 100%;
  min-width: 80px;

  padding: 15px;
  border-radius: 3px;
  font-size: 10px;
  text-align: left;
  line-height: 1.52857142;
  color: white;
  background-color: rgba(0, 0, 0, 0.8);

  box-sizing: border-box;
  overflow: hidden;
}

.custom-toast-content-nobg {
  display: inline-flex;
  align-items: center;
  max-width: 100%;
  min-width: 80px;

  padding: 15px;
  border-radius: 3px;
  font-size: 10px;
  text-align: left;
  line-height: 1.52857142;
  color: white;
  background-color: rgba(0, 0, 0, 0);

  box-sizing: border-box;
  overflow: hidden;
}

.custom-toast-text {
  white-space: nowrap;
  text-overflow: ellipsis;
  overflow: hidden;
}
</style>
