<template>
  <div class="contact">
    <list :list='lcontacts' :headerBackground="'rgb(196, 117, 15)'" :disable="disableList" :title="LangString('APP_CONTACT_TITLE')" @back="back" @select='onSelect' @option='onOption'></list>
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
    ...mapGetters(['LangString', 'contacts']),
    lcontacts () {
      let addContact = { display: this.LangString('APP_CONTACT_NEW'), letter: '+', num: '', id: -1 }
      return [addContact, ...this.contacts.map(e => {
        if (e.icon === null || e.icon === undefined || e.icon === '') {
          e.backgroundColor = e.backgroundColor || generateColorForStr(e.number)
        }
        return e
      })]
    }
  },
  methods: {
    ...mapActions(['updateContactPicture']),
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
      var scelte = [
          {id: 1, title: this.LangString('APP_CONTACT_EDIT'), icons: 'fa-user-circle', color: 'orange'},
          {id: 2, title: this.LangString('APP_CONTACT_ADD_PICTURE'), icons: 'fa-camera'},
          {id: 4, title: this.LangString('APP_CONTACT_SHARE_CONTACT'), icons: 'fa-address-book'},
          {id: 5, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red'}
      ]
      if (isValid === true) { scelte = [{id: 3, title: this.LangString('APP_PHONE_CALL'), icons: 'fa-phone'}, ...scelte] }
      const resp = await Modal.CreateModal({ scelte: scelte })
      // lista delle scelte
      switch (resp.id) {
        case 1:
          this.$router.push({ path: 'contact/' + contact.id })
          this.disableList = false
          break
        case 2:
          const pic = await this.$phoneAPI.takePhoto()
          if (pic && pic !== '') {
            this.updateContactPicture({ id: contact.id, display: contact.display, number: contact.number, icon: pic })
          }
          this.disableList = false
          break
        case 3:
          this.$phoneAPI.startCall({ numero: contact.number })
          this.disableList = false
          break
        case 4:
          this.$router.push({ name: 'messages.chooseinoltra', params: { contact: contact } })
          break
        case 5:
          this.disableList = false
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
