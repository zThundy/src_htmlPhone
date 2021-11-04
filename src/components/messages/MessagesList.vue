<template>
  <div class="screen">
    <list class="fontList" :list='messagesData' :headerBackground="'rgb(194, 108, 7)'" :disable="ignoreControls" :title="LangString('APP_MESSAGE_TITLE')" @back="back" @select="onSelect" @option='onOption'></list>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import { generateColorForStr } from '@/Utils'
import Modal from '@/components/Modal/index.js'
import List from '@/components/List'

export default {
  components: { List },
  data () {
    return {
      ignoreControls: false
    }
  },
  methods: {
    ...mapActions(['deleteMessagesNumber', 'deleteAllMessages', 'startVideoCall']),
    onSelect (data) {
      if (data.id === -1) {
        this.$router.push({name: 'messages.selectcontact'})
      } else {
        this.$router.push({name: 'messages.view', params: data})
      }
    },
    onOption (data) {
      if (data.number === undefined) return
      this.ignoreControls = true
      Modal.CreateModal({
        scelte: [
          {id: 4, title: this.LangString('APP_PHONE_CALL'), icons: 'fa-phone'},
          {id: 5, title: this.LangString('APP_PHONE_CALL_ANONYMOUS'), icons: 'fa-mask'},
          {id: 6, title: this.LangString('APP_MESSAGE_NEW_MESSAGE'), icons: 'fa-sms'}
        ]
        .concat(data.unknowContact ? [{id: 7, title: this.LangString('APP_MESSAGE_SAVE_CONTACT'), icons: 'fa-save'}] : [])
        .concat([
          {id: 1, title: this.LangString('APP_MESSAGE_ERASE_CONVERSATION'), icons: 'fa-trash', color: 'orange'},
          {id: 2, title: this.LangString('APP_MESSAGE_ERASE_ALL_CONVERSATIONS'), icons: 'fa-trash', color: 'red'},
          {id: 3, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red'}
        ])
      }).then(resp => {
        switch(resp.id) {
          case 1:
            this.deleteMessagesNumber({num: data.number})
            break
          case 2:
            this.deleteAllMessages()
            break
          case 3:
            this.ignoreControls = false
            break
          case 4:
            this.$phoneAPI.startCall({ numero: data.number })
            break
          case 5:
            this.$phoneAPI.startCall({ numero: '#' + data.number })
            break
          case 6:
            this.$router.push({ name: 'messages.view', params: data })
            break
          case 7:
            this.$router.push({ name: 'contacts.view', params: { id: 0, number: data.number } })
            break
          case 8:
            this.startVideoCall({ numero: data.number })
            break
        }
      })
      .catch(e => { this.ignoreControls = false })
    },
    back: function () {
      if (this.ignoreControls === true) return
      this.$router.push({ name: 'menu' })
    }
  },
  computed: {
    ...mapGetters(['LangString', 'contacts', 'messages']),
    messagesData () {
      let messages = this.messages
      let contacts = this.contacts
      let messGroup = messages.reduce((rv, x) => {
        if (rv[x['transmitter']] === undefined) {
          const data = { noRead: 0, lastMessage: 0, display: x.transmitter }
          let contact = contacts.find(e => e.number === x.transmitter)
          data.unknowContact = contact === undefined
          if (contact !== undefined) {
            data.display = contact.display
            data.backgroundColor = contact.backgroundColor || generateColorForStr(x.transmitter)
            data.letter = contact.letter
            data.icon = contact.icon
          } else {
            data.backgroundColor = generateColorForStr(x.transmitter)
          }
          rv[x['transmitter']] = data
        }
        if (x.isRead === 0) {
          rv[x['transmitter']].noRead += 1
        }
        if (x.time >= rv[x['transmitter']].lastMessage) {
          rv[x['transmitter']].lastMessage = x.time
          rv[x['transmitter']].keyDesc = x.message
        }
        return rv
      }, {})
      let mess = []
      Object.keys(messGroup).forEach(key => {
        mess.push({
          display: messGroup[key].display,
          puce: messGroup[key].noRead,
          number: key,
          lastMessage: messGroup[key].lastMessage,
          keyDesc: messGroup[key].keyDesc,
          backgroundColor: messGroup[key].backgroundColor,
          icon: messGroup[key].icon,
          letter: messGroup[key].letter,
          unknowContact: messGroup[key].unknowContact
        })
      })
      mess.sort((a, b) => b.lastMessage - a.lastMessage)
      return [this.newMessageOption, ...mess]
    },
    newMessageOption () {
      return {
        backgroundColor: '#C0C0C0',
        display: this.LangString('APP_MESSAGE_NEW_MESSAGE'),
        letter: '+',
        id: -1
      }
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
.screen {
  position: relative;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
}

.fontList {
  color: black;
  font-weight: bold;
}
</style>
