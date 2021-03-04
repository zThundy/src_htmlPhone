<template>
  <div style="width: 326px; height: 743px;" class="sfondo">
    <PhoneTitle :title="this.LangString('APP_WHATSAPP_CHOOSE_CONTACTS')" :backgroundColor="'rgb(112,255,125)'" @back="onBackspace"/>

    <template v-if="currentPage === STATES.SCELTA_PERSONE">
      <div style="width: 324px; height: 595px;" class="phone_content elements">

        <div class="element" v-for='(elem, key) in contacts' :key="elem.id" v-bind:class="{ select: key === currentSelect }">

          <div class="elem-pic" v-bind:style="stylePuce(elem)">{{elem.letter || elem[keyDispay][0]}}</div>

          <div class="checkbox">
            <i v-if="selectedContacts[elem.id]" class="moveFaicon fa fa-check-square-o"></i>
            <i v-else class="moveFaicon fa fa-times"></i>
          </div>
          <div class="checkboxText">{{elem[keyDispay]}}</div>

        </div>

      </div>
    </template>

    <template v-if="currentPage === STATES.INFO_GRUPPO">
      <div style="width: 324px; height: 90%; background-color: rgba(150, 255, 150, 1);" class="phone_content elements">

        <div class="group inputText" data-type="text" data-maxlength='64' :data-defaultValue="tempGroupInfo['title']" data-title="Inserisci il titolo del gruppo">
          <input class="nomeGruppoBox" type="text" :value="tempGroupInfo['title']" @change="updateGroupVars({value: $event.target.value, key: 'title'})">
          <span class="highlight"></span>
          <span class="bar"></span>
          <label>{{ LangString('APP_WHATSAPP_GROUP_NAME') }}</label>
        </div>

        <div style="margin-bottom: 42px; padding-left: 30%;" class="img" data-type="button">
          <img v-if="tempGroupInfo['image']" style="height: 128px; width: 128px; overflow: auto;  border-radius: 100px;" :src="tempGroupInfo['image']">
          <img v-else-if="tempGroupInfo['image'] === null || tempGroupInfo['image'] === undefined"  style="height: 128px; width: 128px; overflow: auto; border-radius: 100px;" src="/html/static/img/app_whatsapp/defaultgroup.png">
        </div>

        <div style="left: 3%; top: 45%; position: absolute;" class="group" data-type="button" @click="snapGroupImage">
          <input type='button' class="btn btn-green" :value="LangString('APP_WHATSAPP_GROUP_AVATAR')"/>
        </div>

        <div style="left: 3%; top: 55%; position: absolute;" class="group" data-type="button" @click="finalizzaGruppo">
          <input type='button' class="btn btn-green" :value="LangString('APP_WHATSAPP_NEW_GROUP')"/>
        </div>

      </div>
    </template>

  </div>
</template>


<script>
import { mapGetters, mapActions } from 'vuex'
import PhoneTitle from './../PhoneTitle'
import Modal from '@/components/Modal/index.js'

const STATES = Object.freeze({
  SCELTA_PERSONE: 0,
  INFO_GRUPPO: 1
})

export default {
  components: { PhoneTitle },
  data () {
    return {
      STATES,
      ignoreControls: false,
      currentSelect: -1,
      currentPage: STATES.SCELTA_PERSONE,
      selectedContacts: [],
      isAddingMembers: false
    }
  },
  props: {
    showHeader: {
      type: Boolean,
      default: true
    },
    color: {
      type: String,
      default: '#FFFFFF'
    },
    backgroundColor: {
      type: String,
      default: '#4CAF50'
    },
    keyDispay: {
      type: String,
      default: 'display'
    }
  },
  computed: {
    ...mapGetters(['LangString', 'contacts', 'tempGroupInfo', 'myPhoneNumber'])
  },
  methods: {
    ...mapActions(['getAllInfoGroups', 'updateGroupVars', 'creaGruppo', 'addSelectedMembers']),
    scrollIntoViewIfNeeded: function () {
      this.$nextTick(() => {
        document.querySelector('.select').scrollIntoViewIfNeeded()
      })
    },
    finalizzaGruppo () {
      var groupInfo = this.tempGroupInfo
      var myInfo = {
        id: -1,
        number: this.myPhoneNumber,
        display: 'Amministratore'
      }
      this.creaGruppo({ selected: this.selectedContacts, contacts: this.contacts, groupTitle: groupInfo.title, groupImage: groupInfo.image, myInfo })
      this.$router.push({ name: 'whatsapp' })
    },
    onUp: function () {
      if (this.ignoreControls === true) return
      if (this.currentPage === this.STATES.INFO_GRUPPO) {
        let select = document.querySelector('.group.select')
        if (select === null) {
          select = document.querySelector('.group')
          select.classList.add('select')
          return
        }
        while (select.previousElementSibling !== null) {
          if (select.previousElementSibling.classList.contains('group')) {
            break
          }
          select = select.previousElementSibling
        }
        if (select.previousElementSibling !== null) {
          document.querySelectorAll('.group').forEach(elem => {
            elem.classList.remove('select')
          })
          select.previousElementSibling.classList.add('select')
          let i = select.previousElementSibling.querySelector('input')
          if (i !== null) {
            i.focus()
          }
        }
      } else {
        this.currentSelect = this.currentSelect === 0 ? this.contacts.length - 1 : this.currentSelect - 1
        this.scrollIntoViewIfNeeded()
      }
    },
    onDown: function () {
      if (this.ignoreControls === true) return
      if (this.currentPage === this.STATES.INFO_GRUPPO) {
        let select = document.querySelector('.group.select')
        if (select === null) {
          select = document.querySelector('.group')
          select.classList.add('select')
          return
        }
        while (select.nextElementSibling !== null) {
          if (select.nextElementSibling.classList.contains('group')) {
            break
          }
          select = select.nextElementSibling
        }
        if (select.nextElementSibling !== null) {
          document.querySelectorAll('.group').forEach(elem => {
            elem.classList.remove('select')
          })
          select.nextElementSibling.classList.add('select')
          let i = select.nextElementSibling.querySelector('input')
          if (i !== null) {
            i.focus()
          }
        }
      } else {
        this.currentSelect = this.currentSelect === this.contacts.length - 1 ? 0 : this.currentSelect + 1
        this.scrollIntoViewIfNeeded()
      }
    },
    async snapGroupImage () {
      this.ignoreControls = true
      let choix = [
        {id: 1, title: this.LangString('APP_CONFIG_LINK_PICTURE'), icons: 'fa-link'},
        {id: 2, title: this.LangString('APP_CONFIG_TAKE_PICTURE'), icons: 'fa-camera'}
      ]
      const resp = await Modal.CreateModal({ choix })
      if (resp.id === 1) {
        Modal.CreateTextModal({ text: 'https://i.imgur.com/' }).then(valueText => {
          if (valueText.text !== '' && valueText.text !== undefined && valueText.text !== null && valueText.text !== 'https://i.imgur.com/') {
            this.ignoreControls = false
            this.updateGroupVars({value: valueText.text, key: 'image'})
            setTimeout(() => {
              this.currentPage = this.STATES.INFO_GRUPPO
            }, 50)
          }
        })
      } else if (resp.id === 2) {
        const pic = await this.$phoneAPI.takePhoto()
        if (pic.url !== null && pic.url !== undefined) {
          this.ignoreControls = false
          this.updateGroupVars({value: pic.url, key: 'image'})
          setTimeout(() => {
            this.currentPage = this.STATES.INFO_GRUPPO
          }, 50)
        }
      }
      // bo questo forse dovrebbe venire chiamato appena l'if
      // ha finito di venire eseguito
      this.currentPage = this.STATES.INFO_GRUPPO
    },
    stylePuce (data) {
      data = data || {}
      if (data.icon !== undefined) {
        return {
          backgroundImage: `url(${data.icon})`,
          backgroundSize: 'cover',
          color: 'rgba(0,0,0,0)',
          borderRadius: '50%'
        }
      }
      return {
        color: data.color || this.color,
        backgroundColor: data.backgroundColor || this.backgroundColor,
        borderRadius: '50%'
      }
    },
    onEnter () {
      if (this.ignoreControls === true) return
      if (this.currentPage === this.STATES.INFO_GRUPPO) {
        let select = document.querySelector('.group.select')
        if (select === null) return
        if (select.dataset !== null) {
          if (select.dataset.type === 'text') {
            const $input = select.querySelector('input')
            this.$phoneAPI.getReponseText({ limit: parseInt(select.dataset.maxlength) || 64, text: select.dataset.defaultValue || '', title: select.dataset.title || '' }).then(data => {
              $input.value = data.text
              $input.dispatchEvent(new window.Event('change'))
            })
          }
          if (select.dataset.type === 'button') {
            select.click()
          }
        }
        return
      } else {
        let contatto = this.contacts[this.currentSelect]
        // con questo prendo il contatto dalla lista tornata dal lua
        // e uso l'indicizzazione a id per aggiornare lo stato della checkbox
        // nella lista sull'html
        if (contatto.selected === undefined || contatto.selected === null) { contatto.selected = false }
        contatto.selected = !contatto.selected
        this.selectedContacts[contatto.id] = !this.selectedContacts[contatto.id]
        setTimeout(() => {
          // ho capito il problema dell'aggiornamento. Il problema non era la checkbox
          // ma la classe select (anche se lo sospettavo già) che non permette la modifica.
          // Facendo così "imbroglio" vuejs forzandolo ad aggiornare il valore
          this.currentSelect = this.currentSelect + 1
          this.currentSelect = this.currentSelect - 1
        }, 5)
      }
    },
    onBackspace () {
      if (this.ignoreControls === true) { this.ignoreControls = false; return }
      if (this.currentPage === this.STATES.INFO_GRUPPO) { this.currentPage = this.STATES.SCELTA_PERSONE; return }
      this.$router.push({ name: 'whatsapp' })
    },
    async onRigth () {
      this.ignoreControls = true
      // qui controllo: se premi destra mentre sei in fase di modifica (vedi whatsapp edit grouo)
      // allora gli creo un modal custom
      if (this.isAddingMembers === null || !this.isAddingMembers) {
        let choix = [
          {id: 1, title: this.LangString('APP_WHATSAPP_NEXT_STEP'), icons: 'fa-arrow-right'},
          {id: 2, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red'}
        ]
        const resp = await Modal.CreateModal({ choix })
        switch (resp.id) {
          case 1:
            this.currentPage = this.STATES.INFO_GRUPPO
            this.ignoreControls = false
            break
          case 2:
            this.$router.push({ name: 'whatsapp' })
            this.ignoreControls = false
            break
        }
      } else {
        let choix = [
          {id: 1, title: this.LangString('APP_WHATSAPP_ADD_MEMBERS'), icons: 'fa-check', color: 'green'},
          {id: 2, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red'}
        ]
        const resp = await Modal.CreateModal({ choix })
        switch (resp.id) {
          case 1:
            this.$router.push({ name: 'whatsapp.gruppo', params: { gruppo: this.gruppo, updategroups: true } })
            this.ignoreControls = false
            this.addSelectedMembers({ contacts: this.contacts, gruppo: this.gruppo, selected: this.selectedContacts })
            break
          case 2:
            this.$router.push({ name: 'whatsapp' })
            this.ignoreControls = false
            break
        }
      }
    }
  },
  created () {
    for (var key in this.contacts) {
      this.selectedContacts[this.contacts[key].id] = false
    }
    this.updateGroupVars({ value: 'Nessun titolo', key: 'title' })
    this.updateGroupVars({ value: '/html/static/img/app_whatsapp/defaultgroup.png', key: 'image' })
    // uso questa variabile per controllare
    // se sei in fase di modifica o no
    if (this.$route.params !== undefined && this.$route.params !== null) {
      this.isAddingMembers = this.$route.params.isAddingMembers
      this.gruppo = this.$route.params.gruppo
      if (this.gruppo !== undefined && this.gruppo !== null) {
        if (this.gruppo.partecipanti !== undefined && this.gruppo.partecipanti !== null) {
          for (var index in this.contacts) {
            let contatto = this.contacts[index]
            if (this.gruppo.partecipanti[Number(contatto.id)] !== undefined && this.gruppo.partecipanti[Number(contatto.id)] !== null) {
              // console.log(String(contatto.number), String(this.gruppo.partecipanti[Number(contatto.id)].number))
              if (String(contatto.number) === String(this.gruppo.partecipanti[Number(contatto.id)].number)) {
                this.selectedContacts[contatto.id] = true
              }
            }
          }
        }
      }
    }
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpArrowRight', this.onRigth)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
    this.$bus.$on('keyUpEnter', this.onEnter)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpArrowRight', this.onRigth)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpEnter', this.onEnter)
  }
}
</script>

<style scoped>
/* ZONA GRUPPO */

.sfondo {
  background-image: url("/html/static/img/app_whatsapp/sfondogruppi.png");
  background-repeat: no-repeat;
  width: auto;
  height: auto;
  margin: 0;
  padding: 0;
}

.nomeGruppoBox {
  opacity: 0.6;
  border-radius: 5px;
  background-color: rgb(228, 228, 228);
}

.checkbox {
  position: absolute;
  left: 22%;
}

.moveFaicon {
  position: relative;
  bottom: 201%;
  right: 1%;
  color: rgb(0, 109, 24);
}

.checkboxText {
  position: absolute;
  left: 30%;
  bottom: 3px;
}

.group {
  position: relative;
  margin-top: 24px;
  height: 60px;
}

.group.inputText {
  position: relative;
  text-align: center;
  margin-top: 50px;
  border-radius: 5px;
}

.group.bottom {
  margin-top: auto;
}

.group.img {
  display: flex;
  flex-direction: row;
  align-items: center;
}

.group.img img{
  display: flex;
  flex-direction: row;
  overflow: auto;
  flex-grow: 0;
  flex: 0 0 128px;
  margin-right: 24px;
  border-radius: 100px;
  object-fit: cover;
}

.group.inputText label {
  color: #999;
  font-size: 18px;
  font-weight: normal;
  position: absolute;
  pointer-events: none;
  left: 26%;
  transition: 0.2s ease all;
  -moz-transition: 0.2s ease all;
  -webkit-transition: 0.2s ease all;
}

.group.select input ~ .bar:before, .group.select input ~ .bar:after{
  width: 50%;
}

.group.inputText input:focus ~ label, .group.inputText input:valid ~ label 		{
  top: -28px;
  font-size: 20px;
  color: #00c932;
}

.group .btn{
  width: 100%;
  padding: 0px 0px;
  height: 48px;
  color: #fff;
  border: 0 none;
  font-size: 22px;
  font-weight: 500;
  line-height: 34px;
  color: #000000;
  background-color: #edeeee;
}

.group.select .btn{
  /* border: 6px solid #C0C0C0; */
  line-height: 18px;
}

.group .btn.btn-green{
  width: 293px;
  margin-left: 6px;
  border: 1px solid #00c932;
  color: #00c932;
  background-color: white;
  font-weight: 500;
  border-radius: 10px;
  font-weight: 300;
  font-size: 19px;
}

.group.select .btn.btn-green, .group:hover .btn.btn-green{
  background-color: #00c932;
  color: white;
  border: none;
}

.group .btn.btn-red{
  border: 1px solid #ee3838;
  color: #ee3838;
  background-color: white;
  font-weight: 200;
  border-radius: 10px;
  width: 193px;
  margin: 0 auto;
  margin-bottom: 50px;
}

.group.select .btn.btn-red, .group:hover .btn.btn-red{
  background-color: #ee3838;
  color: white;
  border: none;
}

.group .btn.btn-gray{
  border: none;
  color: #222;
  background-color: #AAA;
  font-weight: 500;
  border-radius: 10px;
}
.group.select .btn.btn-gray, .group:hover .btn.btn-gray{
  background-color: #757575;
  color: white;
  border: none;
}

/* ZONA BARRE DI SELEZIONE CSS */

.bar 	{ display:block; width:60%; }
.bar:before, .bar:after {
  content:'';
  top: 31px;
  height: 2px;
  width: 0;
  bottom: 1px;
  position:absolute;
  background:#00c932;
  transition:0.2s ease all;
  -moz-transition:0.2s ease all;
  -webkit-transition:0.2s ease all;
}

.bar:before {
  left:31%;
}

.bar:after {
  right:31%;
}

/* ZONA HIGHLIGHT RIGA CSS */

.highlight {
  position:absolute;
  height:60%;
  width:100px;
  top:25%;
  left:0;
  pointer-events:none;
  opacity:0.5;
}

/* ZONA ALTRO CSS */

.generale {
  width: 326px; 
  height: 743px;
}

.elements {
  overflow-y: auto;
}

.element {
  height: 58px;
  line-height: 58px;
  display: flex;
  align-items: center;
  position: relative;
  font-weight: 300;
  background-color: rgba(80, 201, 110, 0.493);
  font-size: 18px;
}

.element.select, .element:hover {
  background-color: rgba(0, 138, 18, 0.384);
}

.elem-title.checked {
  color: rgb(1, 124, 27);
}

.elem-pic {
  margin-left: 12px;
  height: 48px;
  width: 48px;
  text-align: center;
  line-height: 48px;
  font-weight: 200;
}

.elem-title{
  margin-left: 12px;
  font-size: 20px;
  font-weight: 400;
}
</style>
