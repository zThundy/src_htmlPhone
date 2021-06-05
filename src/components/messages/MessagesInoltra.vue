<template>
  <div class="contact">
    <list :headerBackground="'rgb(194, 108, 7)'" :list='lcontacts' :title="LangString('APP_MESSAGES_INOLTRA')" @back="back" @select='onSelect'></list>
  </div>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'
import { generateColorForStr } from '@/Utils'
import List from './../List.vue'
// import Modal from '@/components/Modal/index.js'

export default {
  components: { List },
  data () {
    return {
      tempMessage: ''
    }
  },
  computed: {
    ...mapGetters(['LangString', 'contacts']),
    lcontacts () {
      return [...this.contacts.map(e => {
        if (e.icon === null || e.icon === undefined || e.icon === '') {
          e.backgroundColor = e.backgroundColor || generateColorForStr(e.number)
        }
        e.message = this.tempMessage
        return e
      })]
    }
  },
  methods: {
    ...mapActions(['sendMessage']),
    onSelect (contact) {
      this.sendMessage({ phoneNumber: contact.number, message: this.tempMessage })
      this.$router.push({ name: 'messages.view', params: { number: contact.number, display: contact.display } })
    },
    back () {
      this.tempMessage = ''
      this.$router.push({ name: 'menu' })
    }
  },
  created () {
    if (this.$route.params.message) { this.tempMessage = this.$route.params.message }
    if (this.$route.params.contact) {
      // console.log(this.$route.params.contact)
      var contact = this.$route.params.contact
      this.tempMessage = '[CONTACT]%' + contact.number + '%' + contact.display + '%' + contact.email + '%' + contact.icon
      // console.log(this.tempMessage)
    }
    this.$bus.$on('keyUpBackspace', this.back)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpBackspace', this.back)
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
