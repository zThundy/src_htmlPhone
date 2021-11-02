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
      if (this.ignoreControls) return
      this.updateIgnoredControls(true)
      // qui apro il modal con le opzioni di selezione
      const response = await Modal.CreateModal({scelte: [...itemSelect.subMenu, {title: 'Cancella', icons: 'fa-undo', color: 'red'}]})
      if (response.title === 'Cancella' || response.title === 'cancel') { this.updateIgnoredControls(false); return }
      // dopo aver controllato se effettivamente si preme una opzione valida
      if (response.title !== 'Cancella') {
        Modal.CreateTextModal({ title: this.LangString('APP_PHONE_FAVOURITES_MODAL_TITLE') })
        .then(data => {
          console.log(data)
          if (data.text !== undefined || data.text !== null) {
            // this.$phoneAPI.callEvent(rep.eventName, rep.type)
            this.$phoneAPI.sendEmergencyMessage({ eventName: response.eventName, text: data.text, type: response.type, item: itemSelect })
            // this.$router.push({name: 'menu'})
            setTimeout(() => { this.updateIgnoredControls(false) }, 500)
          }
        })
        .catch((e) => {
          setTimeout(() => { this.updateIgnoredControls(false) }, 500)
        })
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
