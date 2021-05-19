<template>
  <div class="phone_app">
    <PhoneTitle :title="LangString('APP_GALLERIA_TITLE')" backgroundColor="rgb(217, 122, 81)" :titleColor="'black'" />

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
    ...mapGetters(['LangString', 'fotografie', 'bluetooth'])
  },
  methods: {
    ...mapActions(['setBackground', 'clearGallery']),
    scrollIntoView: function () {
      this.$nextTick(() => {
        var elem = this.$el.querySelector('.select')
        if (elem === undefined || elem === null) return
        elem.scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' })
      })
    },
    onUp () {
      if (this.ignoredControls) return
      if (this.currentSelect === 1 || this.currentSelect === 2) return
      this.currentSelect = this.currentSelect - 2
      this.scrollIntoView()
    },
    onDown () {
      if (this.ignoredControls) return
      if (this.currentSelect === this.fotografie.length || this.currentSelect === this.fotografie.length - 1) return
      this.currentSelect = this.currentSelect + 2
      this.scrollIntoView()
    },
    onLeft () {
      if (this.ignoredControls) return
      if (this.currentSelect === 1) return
      this.currentSelect = this.currentSelect - 1
      this.scrollIntoView()
    },
    onRight () {
      if (this.ignoredControls) return
      if (this.currentSelect === this.fotografie.length) return
      this.currentSelect = this.currentSelect + 1
      this.scrollIntoView()
    },
    onBackspace () {
      if (this.ignoredControls) return
      this.$router.push({ name: 'menu' })
    },
    async onEnter () {
      if (this.fotografie.length === 0) return
      if (this.ignoredControls) return
      var foto = this.fotografie[this.currentSelect - 1]
      this.ignoredControls = true
      try {
        let choix = [
          { id: 1, title: this.LangString('APP_GALLERIA_SET_WALLPAPER'), icons: 'fa-mobile' },
          { id: 2, title: this.LangString('APP_GALLERIA_INOLTRA'), icons: 'fa-paper-plane' },
          { id: 4, title: this.LangString('APP_GALLERIA_SEND_BLUETOOTH'), icons: 'fa-share-square' },
          { id: 3, title: this.LangString('APP_GALLERIA_ELIMINA_TUTTO'), icons: 'fa-trash', color: 'orange' },
          { id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' }
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
          case 4:
            if (this.bluetooth) {
              try {
                this.ignoredControls = true
                let choix = []
                var cancel = { id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' }
                var closestPlayers = this.$phoneAPI.getClosestPlayers()
                for (var i in this.closestPlayers) { choix.push({ id: this.closestPlayers[i].id, label: this.closestPlayers[i].name, title: this.closestPlayers[i].name, icons: 'fa-share-square' }) }
                choix.push(cancel)
                const data = await Modal.CreateModal({ choix })
                if (data.id === -1) {
                  this.ignoredControls = false
                } else {
                  this.ignoredControls = false
                  this.$phoneAPI.sendPicToUser({ id: data.id, message: foto.link })
                }
              } catch (e) { } finally { this.ignoredControls = false }
            } else {
              this.$phoneAPI.sendErrorMessage('Il bluetooth è disattivo')
              this.ignoredControls = false
            }
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

  background-color: white;
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
  border: 3px solid rgb(205, 116, 76);
  filter: brightness(90%)
}
</style>
