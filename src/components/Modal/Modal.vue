<template>
  <transition name="modal">

    <div class="modal-mask">
      <div class="modal-container">

        <div class="modal-scelte" v-for="(val, index) in scelte" :key='index' :style="{ color: val.color }" :class="{ select: index === currentSelect }">
          <i class="fas" :class="val.icons"></i>{{val.title}}
        </div>

      </div>
    </div>

  </transition>
</template>

<script>
import store from './../../store'
import { mapGetters } from 'vuex'

export default {
  name: 'Modal',
  store: store,
  data () {
    return {
      currentSelect: 0
    }
  },
  props: {
    scelte: {
      type: Array,
      default: () => []
    }
  },
  computed: {
    ...mapGetters([])
  },
  methods: {
    scrollIntoView () {
      this.$nextTick(() => {
        document.querySelector('.modal-scelte.select').scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' })
      })
    },
    onUp () {
      this.currentSelect = this.currentSelect === 0 ? 0 : this.currentSelect - 1
      this.scrollIntoView()
    },
    onDown () {
      this.currentSelect = this.currentSelect === this.scelte.length - 1 ? this.currentSelect : this.currentSelect + 1
      this.scrollIntoView()
    },
    selectItem (elem) {
      this.$emit('select', elem)
    },
    onEnter () {
      if (this.scelte.length > 0) {
        this.$emit('select', this.scelte[this.currentSelect])
        this.scelte = []
      }
    },
    cancel () {
      this.$emit('cancel')
    }
  },
  created () {
    if (this.scelte.length > 0) {
      this.$bus.$on('keyUpArrowDown', this.onDown)
      this.$bus.$on('keyUpArrowUp', this.onUp)
      this.$bus.$on('keyUpEnter', this.onEnter)
      this.$bus.$on('keyUpBackspace', this.cancel)
    }
  },
  beforeDestroy () {
    if (this.scelte.length > 0) {
      this.$bus.$off('keyUpArrowDown', this.onDown)
      this.$bus.$off('keyUpArrowUp', this.onUp)
      this.$bus.$off('keyUpEnter', this.onEnter)
      this.$bus.$off('keyUpBackspace', this.cancel)
    }
  }
}
</script>

<style scoped>
.modal-mask {
  position: absolute;
  z-index: 99;
  top: 0;
  left: 0;
  width: 334px;
  height: 738px;
  background-color: rgba(0, 0, 0, .3);
  display: flex;
  align-items: flex-end;
  transition: opacity .3s ease;
}

.modal-container {
  width: 100%;
  margin: 0;
  padding: 0;
  background-color: #fff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, .33);
  transition: all .3s ease;
  padding-bottom: 16px;
  max-height: 100%;
  overflow-y: auto;

  transition: all 0.1s ease-in-out;
  border-radius: 15px 15px 0px 0px;
}

.modal-title {
  text-align: center;
  height: 32px;
  line-height: 32px;
  color: #42B2DC;
  border-bottom: 2px solid #42B2DC;
}

.modal-scelte {
  font-size: 15px;
  height: 56px;
  line-height: 56px;
  color: gray;
  position: relative;
  font-weight: 400;
}

.modal-scelte .fa, .modal-scelte .fas {
  font-size: 18px;
  line-height: 24px;
  margin-left: 12px;
  margin-right: 12px;
}

.modal-scelte .picto {
  z-index: 500;
  position: absolute;
  width: 42px;
  background-size: 100% !important;
  background-position-y: 100%;
  height: 42px;
}

.modal-scelte.select {
  background-color: rgba(209, 209, 209, 0.3);
  color: #0079d3
}

.modal-container {
  animation-name: up;
  animation-duration: 0.2s;
  animation-fill-mode: forwards;
  /*transition: all 0.5s ease-in-out;*/
}

@keyframes up {
  from {transform: translateY(100vh);}
  to {transform: translateY(0);}
}


</style>
