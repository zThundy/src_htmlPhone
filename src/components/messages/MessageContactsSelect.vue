<template>
  <div class="contact">
    <list :headerBackground="'rgb(194, 108, 7)'" :list='lcontacts' :title="LangString('APP_MESSAGE_CONTACT_TITLE')" v-on:select="onSelect" @back="back"></list>
  </div>
</template>

<script>
import List from './../List.vue'
import { mapGetters } from 'vuex'
import Modal from '@/components/Modal/index.js'

export default {
  components: { List },
  data () {
    return {}
  },
  computed: {
    ...mapGetters(['LangString', 'contacts']),
    lcontacts () {
      let addContact = {
        display: this.LangString('APP_MESSAGE_CONTRACT_ENTER_NUMBER'),
        letter: '+',
        backgroundColor: 'orange',
        num: -1
      }
      return [addContact, ...this.contacts]
    }
  },
  methods: {
    onSelect (contact) {
      if (contact.num === -1) {
        Modal.CreateTextModal({
          title: this.LangString('APP_PHONE_ENTER_NUMBER'),
          limit: 10,
          color: 'rgb(194, 108, 7)'
        })
        .then(resp => {
          const message = resp.text.trim()
          if (message !== '') this.$router.push({ name: 'messages.view', params: { number: message, display: message } })
        })
        .catch(e => { })
      } else {
        this.$router.push({name: 'messages.view', params: contact})
      }
    },
    onBack () {
      this.$router.push({ name: 'menu' })
    }
  },
  created () {
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.contact{
  position: relative;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
}
</style>
