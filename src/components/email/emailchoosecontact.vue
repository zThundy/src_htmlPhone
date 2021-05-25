<template>
  <div style="width: 100%; height: 743px;" class="contact">
    <PhoneTitle :title="LangString('APP_EMAIL_CHOOSE_CONTACT')" :backgroundColor="'rgb(216, 71, 49)'" />

    <list :list='lcontacts' :showHeader="false" :disable="disableList" :title="LangString('APP_CONTACT_TITLE')" @back="back" @select='onSelect'></list>
  </div>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'
import { generateColorForStr } from '@/Utils'

import PhoneTitle from './../PhoneTitle'
import List from './../List.vue'

export default {
  name: 'email.choosecontacts',
  components: { List, PhoneTitle },
  data () {
    return {
      disableList: false,
      tempEmail: []
    }
  },
  computed: {
    ...mapGetters(['LangString', 'contacts']),
    lcontacts () {
      return [...this.contacts.map(e => {
        if (e.icon === null || e.icon === undefined || e.icon === '') {
          e.backgroundColor = e.backgroundColor || generateColorForStr(e.number)
        }
        return e
      })]
    }
  },
  methods: {
    ...mapActions([]),
    onSelect (contact) {
      this.$router.push({ name: 'email.write', params: { email: this.tempEmail, contact: contact } })
    },
    back () {
      if (this.disableList === true) {
        this.disableList = false
        return
      }
      history.back()
    }
  },
  created () {
    this.tempEmail = this.$route.params.email
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
