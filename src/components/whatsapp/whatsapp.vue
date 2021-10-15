<template>
  <div style="width: 330px; height: 100%;">
    <PhoneTitle :title="LangString('APP_WHATSAPP_TITLE')" :textColor="'black'" :backgroundColor="'rgb(112,255,125)'" @back="onBackspace"/>

    <div v-for="(s, i) in gruppi" :key="s.gruppo" class="whatsapp-menu-item" :class="{ select: i === currentSelected }">
      <img :src="hasImage(s)" class="immagineGruppo">
      <div class="titoloGruppo">{{ formatEmoji(s.gruppo) }}
        <div class="sottotitoloGruppo">{{ s.partecipantiString }}</div>
      </div>
    </div>

  </div>
</template>


<script>
import { mapGetters, mapActions } from 'vuex'
import PhoneTitle from './../PhoneTitle'
import Modal from '@/components/Modal/index.js'

export default {
  components: { PhoneTitle },
  data () {
    return {
      currentSelected: -1,
      ignoreControls: false
    }
  },
  computed: {
    ...mapGetters(['LangString', 'gruppi', 'myPhoneNumber', 'hasWifi'])
  },
  methods: {
    // ...mapMutations(['SET_DATI_INFO']),
    ...mapActions(['leaveGroup']),
    formatEmoji (message) {
      return this.$phoneAPI.convertEmoji(message)
    },
    scrollIntoView () {
      this.$nextTick(() => {
        const elem = this.$el.querySelector('.select')
        if (elem !== null) {
          elem.scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' })
        }
      })
    },
    hasImage (selectedGroup) {
      // console.log(selectedGroup.icona, 'sono nel file vue di whatsapp')
      if (selectedGroup.icona !== null && selectedGroup.icona !== undefined) {
        return selectedGroup.icona
      } else {
        return '/html/static/img/app_whatsapp/defaultgroup.png'
      }
    },
    onUp () {
      if (this.ignoreControls === true) return
      if (this.gruppi.length === 0) { this.currentSelected = -1; return }
      if (this.currentSelected === -1) {
        this.selectMessage = 0
      } else {
        this.currentSelected = this.currentSelected === 0 ? 0 : this.currentSelected - 1
      }
      this.scrollIntoView()
    },
    onDown () {
      if (this.ignoreControls === true) return
      if (this.gruppi.length === 0) { this.currentSelected = -1; return }
      if (this.currentSelected === -1) {
        this.currentSelected = 0
      } else {
        this.currentSelected = this.currentSelected === this.gruppi.length - 1 ? this.currentSelected : this.currentSelected + 1
      }
      this.scrollIntoView()
    },
    async onRight () {
      if (this.ignoreControls === true) return
      this.ignoreControls = true
      // con questo controllo se il telefono
      // ha il wifi attivo
      // DECOMMENTARE SE SI VUOLE SOLO SOTTO WIFI if (!this.hasWifi) {
      // DECOMMENTARE SE SI VUOLE SOLO SOTTO WIFI   this.$phoneAPI.sendErrorMessage('Non sei connesso al wifi')
      // DECOMMENTARE SE SI VUOLE SOLO SOTTO WIFI   return
      // DECOMMENTARE SE SI VUOLE SOLO SOTTO WIFI }
      // qui controllo se il numero che ha salvato il telefono in memoria
      // è valido oppure no
      if (this.myPhoneNumber.includes('#') || this.myPhoneNumber === 0 || this.myPhoneNumber === '0') {
        this.$phoneAPI.ongenericNotification({
          title: 'WHATSAPP_INFO_TITLE',
          message: 'WHATSAPP_CANNOT_GET_PHONE_NUMBER',
          icon: 'whatsapp',
          backgroundColor: 'rgb(108, 250, 108)',
          appName: 'Whatsapp'
        })
        return
      }
      let scelte = []
      if (this.currentSelected !== -1) {
        let gruppo = this.gruppi[this.currentSelected]
        scelte = [
          {id: 3, title: this.LangString('APP_WHATSAPP_EDIT_GROUP'), icons: 'fa-cog', gruppo: gruppo},
          {id: 1, title: this.LangString('APP_WHATSAPP_QUIT_GROUP'), icons: 'fa-trash', color: 'firebrick', gruppo: gruppo}
        ]
        if (!gruppo.partecipanti) gruppo.partecipanti = {}
        if (gruppo.partecipanti.creator.number === this.myPhoneNumber) {
          scelte = [{id: 4, title: this.LangString('APP_WHATSAPP_DELETE_GROUP'), icons: 'fa-trash', color: 'red', gruppo: gruppo}, ...scelte]
        }
      } else {
        scelte = [{id: 2, title: this.LangString('APP_WHATSAPP_NEW_GROUP'), icons: 'fa-plus', color: 'green'}]
      }
      const resp = await Modal.CreateModal({ scelte: scelte })
      switch (resp.id) {
        case 1:
          this.ignoreControls = false
          if (this.currentSelected === 1 || this.gruppi.length === 0) { this.currentSelected = -1 } else { this.currentSelected = 0 }
          this.leaveGroup(resp.gruppo)
          break
        case 2:
          this.ignoreControls = false
          this.$router.push({ name: 'whatsapp.newgruppo' })
          break
        case 3:
          this.ignoreControls = false
          this.$router.push({ name: 'whatsapp.editgroup', params: { gruppo: resp.gruppo } })
          break
        case 4:
          this.ignoreControls = false
          this.$phoneAPI.post('deleteWhatsappGroup', { gruppo: resp.gruppo })
          break
      }
    },
    onBackspace () {
      if (this.ignoreControls === true) { this.ignoreControls = false; return }
      if (this.currentSelected !== -1) { this.currentSelected = -1; return }
      this.$router.push({ name: 'menu' })
    },
    onEnter () {
      if (this.currentSelected === -1) return
      if (this.ignoreControls === true) return
      // qui invio il gruppo al router
      // DECOMMENTARE SE SI VUOLE SOLO SOTTO WIFI if (!this.hasWifi) {
      // DECOMMENTARE SE SI VUOLE SOLO SOTTO WIFI   this.$phoneAPI.sendErrorMessage('Non sei connesso al wifi')
      // DECOMMENTARE SE SI VUOLE SOLO SOTTO WIFI   return
      // DECOMMENTARE SE SI VUOLE SOLO SOTTO WIFI }
      if (!this.gruppi[this.currentSelected].icona) { this.gruppi[this.currentSelected].icona = '/html/static/img/app_whatsapp/defaultgroup.png' }
      this.$router.push({ name: 'whatsapp.gruppo', params: { gruppo: this.gruppi[this.currentSelected] } })
    }
  },
  created () {
    this.$phoneAPI.requestInfoOfGroups()
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
    this.$bus.$on('keyUpEnter', this.onEnter)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpEnter', this.onEnter)
  }
}
</script>

<style scoped>
.generale {
  width: 326px; 
  height: 743px;
}

.whatsapp-menu-item {
  flex-grow: 1;
  flex-basis: 0;
  height: 75px;
  padding-top: 10px;
  padding-left: 10px;
  display: flex;
  color: rgb(108, 250, 108);
}

.whatsapp-menu-item.select {
  background-color: #00ac0e62;
}

.immagineGruppo {
  position: relative;
  object-fit: cover;
  width: 55px;
  height: 55px;
  border-radius: 80px;
  left: 2px;
}

.titoloGruppo {
  color: black;
  padding-left: 9px;
  font-weight: bold;
}

.sottotitoloGruppo {
  color: gray;
  margin-top: 4px;
  padding-left: 6px;
  font-size: 12px;
}

</style>
