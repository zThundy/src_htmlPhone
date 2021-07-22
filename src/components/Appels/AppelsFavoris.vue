<template>
  <div>
    <list :headerBackground="'rgb(6, 152, 87)'" :list='callList' :showHeader="false" :disable='ignoreControls' v-on:select="onSelect"></list>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import List from './../List.vue'
import Modal from '@/components/Modal/index.js'

export default {
  name: 'Favoris',
  components: { List },
  data () {
    return { }
  },
  computed: {
    ...mapGetters(['LangString', 'config', 'ignoreControls']),
    callList () {
      return this.config.serviceCall || []
    }
  },
  methods: {
    ...mapActions(['updateIgnoredControls']),
    async onSelect (itemSelect) {
      if (this.ignoreControls === true) return
      this.updateIgnoredControls(true)
      // qui apro il modal con le opzioni di selezione
      const response = await Modal.CreateModal({scelte: [...itemSelect.subMenu, {title: 'Cancella', icons: 'fa-undo', color: 'red'}]})
      if (response.title === 'Cancella' || response.title === 'cancel') { this.updateIgnoredControls(false); return }
      // dopo aver controllato se effettivamente si preme una opzione valida
      if (response.title !== 'Cancella') {
        const data = await Modal.CreateTextModal({ title: this.LangString('APP_PHONE_FAVOURITES_MODAL_TITLE') })
        if (data.text !== undefined || data.text !== null) {
          this.updateIgnoredControls(false)
          // this.$phoneAPI.callEvent(rep.eventName, rep.type)
          this.$phoneAPI.sendEmergencyMessage({ eventName: response.eventName, text: data.text, type: response.type, item: itemSelect })
          // this.$router.push({name: 'menu'})
        }
      }
    }
  },

  created () {
  },

  beforeDestroy () {
  }
}
</script>

<style scoped>

</style>
