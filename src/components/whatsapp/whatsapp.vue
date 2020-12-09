<template>
  <div style="width: 326px; height: 743px;">
    <PhoneTitle :title="this.IntlString('APP_WHATSAPP_TITLE')" :textColor="'black'" :backgroundColor="'rgb(112,255,125)'" @back="onBackspace"/>

    <div v-for="(s, i) in gruppi" :key="i" class="whatsapp-menu-item" :class="{select: i === currentSelected}">
      <img :src="hasImage(s)" class="immagineGruppo">
      <div class="titoloGruppo">{{s.gruppo}}
        <div class="sottotitoloGruppo">{{s.partecipantiString}}</div>
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
    ...mapGetters(['IntlString', 'gruppi', 'myPhoneNumber'])
  },
  methods: {
    // ...mapMutations(['SET_DATI_INFO']),
    ...mapActions(['leaveGroup']),
    scrollIntoViewIfNeeded () {
      this.$nextTick(() => {
        const elem = this.$el.querySelector('.select')
        if (elem !== null) {
          elem.scrollIntoViewIfNeeded()
        }
      })
    },
    hasImage (selectedGroup) {
      // console.log(selectedGroup.icona, 'sono nel file vue di whatsapp')
      if (selectedGroup.icona !== null && selectedGroup.icona !== undefined) {
        return selectedGroup.icona
      } else {
        return 'html/static/img/app_whatsapp/defaultgroup.png'
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
      this.scrollIntoViewIfNeeded()
    },
    onDown () {
      if (this.ignoreControls === true) return
      if (this.gruppi.length === 0) { this.currentSelected = -1; return }
      if (this.currentSelected === -1) {
        this.currentSelected = 0
      } else {
        this.currentSelected = this.currentSelected === this.gruppi.length - 1 ? this.currentSelected : this.currentSelected + 1
      }
      this.scrollIntoViewIfNeeded()
    },
    async onRight () {
      if (this.ignoreControls === true) return
      // qui controllo se il numero che ha salvato il telefono in memoria
      // è valido oppure no
      if (this.myPhoneNumber.includes('#') || this.myPhoneNumber === 0 || this.myPhoneNumber === '0') {
        this.$phoneAPI.onwhatsapp_showError({ title: 'Errore', message: 'Impossibile ottenere il numero di telefono' })
        return
      }
      let gruppo = this.gruppi[this.currentSelected]
      this.ignoreControls = true
      let scelte = [
        {id: 3, title: this.IntlString('APP_WHATSAPP_EDIT_GROUP'), icons: 'fa-cog'},
        {id: 1, title: this.IntlString('APP_WHATSAPP_QUIT_GROUP'), icons: 'fa-trash', color: 'red'}
      ]
      if (this.currentSelected === -1) {
        scelte = [
          {id: 0, title: this.IntlString('APP_WHATSAPP_SETTINGS'), icons: 'fa-cog'},
          {id: 2, title: this.IntlString('APP_WHATSAPP_NEW_GROUP'), icons: 'fa-plus', color: 'green'}
        ]
      }
      const rep = await Modal.CreateModal({ choix: scelte })
      switch (rep.id) {
        case 0:
          this.ignoreControls = false
          break
        case 1:
          this.ignoreControls = false
          if (this.currentSelected === 1 || this.gruppi.length === 0) { this.currentSelected = -1 } else { this.currentSelected = 0 }
          this.leaveGroup(gruppo)
          break
        case 2:
          this.ignoreControls = false
          // this.$router.push({ name: 'whatsapp.gruppo', params: { gruppo: this.gruppi[this.currentSelected] } })
          this.$router.push({ name: 'whatsapp.newgruppo' })
          break
        case 3:
          this.ignoreControls = false
          this.$router.push({ name: 'whatsapp.editgroup', params: { gruppo: gruppo } })
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
      // console.log(this.gruppi[this.currentSelected])
      this.$router.push({ name: 'whatsapp.gruppo', params: { gruppo: this.gruppi[this.currentSelected] } })
    }
  },
  created () {
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
  padding-left: 5px;
  display: flex;
  color: rgb(108, 250, 108);
}

.whatsapp-menu-item.select {
  background-color: #00ac0e62;
}

.whatsapp-menu-item:hover {
  background-color: #00ac0e62;
}

.immagineGruppo {
  width: 60px;
  height: 60px;
  border-radius: 80px;
}

.titoloGruppo {
  color: black;
  padding-left: 5px;
  font-weight: bold;
}

.sottotitoloGruppo {
  color: gray;
  padding-left: 10px;
  font-size: 15px;
}

</style>
