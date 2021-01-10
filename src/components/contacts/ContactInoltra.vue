<template>
  <div class="contact">

    <list :list='lcontacts' :title="IntlString('APP_CONTACT_INOLTRA')" @back="back" @select='onSelect'></list>
  
  </div>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'
import { generateColorForStr } from '@/Utils'
import List from './../List.vue'

// import PhoneAPI from './../../PhoneAPI'
// import Modal from '@/components/Modal/index.js'

export default {
  name: 'contacts.chooseinoltra',
  components: { List },
  data () {
    return {
      contact: []
    }
  },
  computed: {
    ...mapGetters(['IntlString', 'contacts']),
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
      var message = '%CONTACT%:' + (this.contact.number || '') + '::' + (this.contact.display || '') + '::' + (this.contact.email || '') + ':'
      // console.log(message)
      this.sendMessage({ phoneNumber: contact.number, message: message })
      this.$router.push({ name: 'messages.view', params: { number: contact.number, display: contact.display } })
    },
    back () {
      this.contact = []
      this.$router.push({ name: 'contacts' })
    }
  },
  created () {
    if (this.$route.params.contact) { this.contact = this.$route.params.contact }
    this.$bus.$on('keyUpBackspace', this.back)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpBackspace', this.back)
  }
}
</script>

<style scoped>
.contact {
  position: relative;

  left: 0;
  top: 0;

  width: 100%;
  height: 100%;
}
</style>
