<template>
  <div style="width: 326px; height: 100%; backgroundColor: white" class="contact">

    <list :list='lcontacts' :disable="disableList" :title="IntlString('APP_CONTACT_TITLE')" @back="back" @select='onSelect' @option='onOption'></list>
  
  </div>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'
import { generateColorForStr } from '@/Utils'
import List from './../List.vue'
import Modal from '@/components/Modal/index.js'

export default {
  name: 'contacts',
  components: { List },
  data () {
    return {
      disableList: false
    }
  },
  computed: {
    ...mapGetters(['IntlString', 'contacts']),
    lcontacts () {
      let addContact = { display: this.IntlString('APP_CONTACT_NEW'), letter: '+', num: '', id: -1 }
      return [addContact, ...this.contacts.map(e => {
        if (e.icon === null || e.icon === undefined || e.icon === '') {
          e.backgroundColor = e.backgroundColor || generateColorForStr(e.number)
        }
        return e
      })]
    }
  },
  methods: {
    ...mapActions(['updateContactPicture', 'startCall']),
    onSelect (contact) {
      if (contact.id === -1) {
        this.$router.push({ name: 'contacts.view', params: { id: contact.id } })
        // this.$router.push({ name: 'contacts.view', params: { id: contact.id } })
      } else {
        this.$router.push({ name: 'messages.view', params: { number: contact.number, display: contact.display } })
      }
    },
    async onOption (contact) {
      if (contact.id === -1 || contact.id === undefined) return
      const isValid = contact.number.startsWith('#') === false
      this.disableList = true
      var choix = [
          {id: 1, title: this.IntlString('APP_CONTACT_EDIT'), icons: 'fa-user-circle', color: 'orange'},
          {id: 2, title: this.IntlString('APP_CONTACT_ADD_PICTURE'), icons: 'fa-camera'},
          // {id: 5, title: this.IntlString('APP_CONTACT_SHARE_CONTACT'), icons: 'fa-address-book'},
          {id: 4, title: this.IntlString('CANCEL'), icons: 'fa-undo', color: 'red'}
      ]
      if (isValid === true) { choix = [{id: 3, title: this.IntlString('APP_PHONE_CALL'), icons: 'fa-phone'}, ...choix] }
      const resp = await Modal.CreateModal({ choix: choix })
      // lista delle scelte
      switch (resp.id) {
        case 1:
          this.$router.push({ path: 'contact/' + contact.id })
          this.disableList = false
          break
        case 2:
          const newAvatar = await this.$phoneAPI.takePhoto()
          if (newAvatar.url !== null && newAvatar.url !== undefined && newAvatar !== '') {
            this.updateContactPicture({ id: contact.id, display: contact.display, number: contact.number, icon: newAvatar.url })
          }
          this.disableList = false
          break
        case 3:
          this.startCall({ numero: contact.number })
          this.disableList = false
          break
        case 4:
          this.disableList = false
          break
        case 5:
          this.$router.push({ name: 'contacts.chooseinoltra', params: { contact: contact } })
          // this.$phoneAPI.shareContact(contact)
          break
      }
    },
    back () {
      if (this.disableList === true) {
        this.disableList = false
        return
      }
      this.$router.push({ name: 'menu' })
    }
  },
  created () {
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
