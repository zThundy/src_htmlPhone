<template>
  <div class="phone_app">
    <PhoneTitle :title="IntlString('APP_GALLERIA_TITLE')" backgroundColor="rgb(200, 200, 200)" :titleColor="'black'" />

    <div class="div_immagini">
      
      <div class='immagini'
        v-for="(val, key) of fotografie" 
        :key="key + 1" 
        :style="{ src: 'url(' + val.link +')' }"
      >
        <img class="immagine" :src="val.link" :class="{ select: key + 1 === currentSelect }" />
      </div>
    </div>

  </div>
</template>

<script>
import PhoneTitle from '@/components/PhoneTitle'
import { mapGetters, mapActions } from 'vuex'
import Modal from '@/components/Modal/index.js'

export default {
  name: 'galleria',
  components: { PhoneTitle },
  data () {
    return {
      currentSelect: 1,
      ignoredControls: false
    }
  },
  computed: {
    ...mapGetters(['IntlString', 'fotografie'])
  },
  methods: {
    ...mapActions(['setBackground', 'clearGallery']),
    scrollIntoViewIfNeeded: function () {
      this.$nextTick(() => {
        this.$el.querySelector('.select').scrollIntoViewIfNeeded()
      })
    },
    onUp () {
      if (this.ignoredControls) return
      if (this.currentSelect === 1 || this.currentSelect === 2) return
      this.currentSelect = this.currentSelect - 2
      this.scrollIntoViewIfNeeded()
    },
    onDown () {
      if (this.ignoredControls) return
      if (this.currentSelect === this.fotografie.length || this.currentSelect === this.fotografie.length - 1) return
      this.currentSelect = this.currentSelect + 2
      this.scrollIntoViewIfNeeded()
    },
    onLeft () {
      if (this.ignoredControls) return
      if (this.currentSelect === 1) return
      this.currentSelect = this.currentSelect - 1
      this.scrollIntoViewIfNeeded()
    },
    onRight () {
      if (this.ignoredControls) return
      if (this.currentSelect === this.fotografie.length) return
      this.currentSelect = this.currentSelect + 1
      this.scrollIntoViewIfNeeded()
    },
    onBackspace () {
      if (this.ignoredControls) return
      this.$router.push({ name: 'menu' })
    },
    async onEnter () {
      if (this.ignoredControls) return
      var foto = this.fotografie[this.currentSelect]
      this.ignoredControls = true
      try {
        let choix = [
          { id: 1, title: this.IntlString('APP_GALLERIA_SET_WALLPAPER'), icons: 'fa-mobile' },
          { id: 2, title: this.IntlString('APP_GALLERIA_INOLTRA'), icons: 'fa-paper-plane' },
          { id: 3, title: this.IntlString('APP_GALLERIA_ELIMINA_TUTTO'), icons: 'fa-trash', color: 'red' },
          { id: -1, title: this.IntlString('CANCEL'), icons: 'fa-undo', color: 'red' }
        ]
        const data = await Modal.CreateModal({ choix })
        switch (data.id) {
          case 1:
            this.setBackground({ label: 'Personalizzato', value: foto.link })
            this.ignoredControls = false
            break
          case 2:
            this.$router.push({ name: 'messages.chooseinoltra', params: { message: foto.link } })
            this.ignoredControls = false
            break
          case 3:
            this.clearGallery()
            this.ignoredControls = false
            break
        }
      } catch (e) { } finally { this.ignoredControls = false }
    }
  },

  created () {
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
    this.$bus.$on('keyUpEnter', this.onEnter)
  },

  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpEnter', this.onEnter)
  }
}
</script>

<style scoped>
.div_immagini {
  position: relative;
  width: 100%;
  height: 650px;
  padding: 7px 8px;
  display: flex;
  flex-wrap: wrap;
  align-content: flex-start;
  overflow-y: scroll;
}

.immagini {
  margin-bottom: 2px;
  width: 98%;
  height: 85px;
  flex: 0 50%;
}

.immagine {
  width: inherit;
  height: inherit;
}

.immagine.select {
  border: 6px solid rgb(129, 129, 129);
  filter: brightness(70%)
}
</style>
