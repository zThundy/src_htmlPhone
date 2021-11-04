<template>
  <div class="sfondo">
    <PhoneTitle :title="this.LangString('APP_WHATSAPP_EDIT_GROUP')" :backgroundColor="'rgb(112,255,125)'" @back="onBackspace"/>

    <div class="elements">

      <div class="group inputText" data-type="text" data-maxlength='64' :data-defaultValue="gruppo.gruppo" :class="{select: 1 === currentSelect}" data-title="Digita il nome del gruppo">
        <input class="nomeGruppoBox" type="text" :value="gruppo.gruppo">
        <span class="highlight"></span>
        <span class="bar"></span>
        <label>{{ LangString('APP_WHATSAPP_GROUP_NAME') }}</label>
      </div>

      <div style="margin-bottom: 42px; padding-left: 30%;" class="img" data-type="button">
        <img v-if="gruppo.icona" :src="gruppo.icona">
        <img v-else-if="gruppo.icona === null || gruppo.icona === undefined" src="/html/static/img/app_whatsapp/defaultgroup.png">
      </div>

      <div class="group genericButton" data-type="button" :class="{select: 2 === currentSelect}" @click="addNewMembers">
        <input type='button' class="btn btn-green" :value="LangString('APP_WHATSAPP_ADD_MEMBERS')"/>
      </div>

      <div class="group genericButton" data-type="button" :class="{select: 3 === currentSelect}" @click="snapGroupImage">
        <input type='button' class="btn btn-green" :value="LangString('APP_WHATSAPP_GROUP_AVATAR')"/>
      </div>

      <div class="group genericButton" data-type="button" :class="{select: 4 === currentSelect}" @click="modificaGruppo">
        <input type='button' class="btn btn-green" :value="LangString('APP_WHATSAPP_EDIT_GROUP')"/>
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
      ignoreControls: false,
      currentSelect: 1,
      gruppo: []
    }
  },
  computed: {
    ...mapGetters(['LangString'])
  },
  methods: {
    ...mapActions(['editGroupTitle', 'editGroupIcon']),
    onUp () {
      if (this.ignoreControls) return
      if (this.currentSelect === 1) return
      this.currentSelect = this.currentSelect - 1
    },
    onDown () {
      if (this.ignoreControls) return
      if (this.currentSelect === 4) return
      this.currentSelect = this.currentSelect + 1
    },
    snapGroupImage () {
      this.ignoreControls = true
      Modal.CreateModal({ scelte: [
        {id: 1, title: this.LangString('APP_CONFIG_LINK_PICTURE'), icons: 'fa-link'},
        {id: 2, title: this.LangString('APP_CONFIG_TAKE_PICTURE'), icons: 'fa-camera'}
      ] })
      .then(async response => {
        switch(response.id) {
          case 1:
            Modal.CreateTextModal({
              text: 'https://i.imgur.com/',
              title: this.LangString('TYPE_LINK'),
              color: 'rgb(112, 255, 125)',
              limit: 64
            })
            .then(resp => {
              if (resp.text !== '' && resp.text !== undefined && resp.text !== null && resp.text !== 'https://i.imgur.com/') {
                this.ignoreControls = false
                this.editGroupIcon({ text: resp.text, gruppo: this.gruppo })
              }
            })
            .catch(e => { this.ignoreControls = false })
            break
          case 2:
            this.$phoneAPI.takePhoto()
            .then(pic => {
              this.editGroupIcon({ text: pic, gruppo: this.gruppo })
              this.ignoreControls = false
            })
            .catch(e => { this.ignoreControls = false })
            break
        }
      })
      .catch(e => { this.ignoreControls = false })
    },
    async modificaGruppo () {
      this.$router.push({ name: 'whatsapp' })
    },
    async addNewMembers () {
      this.$router.push({ name: 'whatsapp.newgruppo', params: { isAddingMembers: true, gruppo: this.gruppo } })
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
      if (this.ignoreControls) return
      let select = document.querySelector('.select')
      if (select === null) return
      if (select.dataset.type === 'button') {
        select.click()
      }
      if (select.dataset.type === 'text') {
        Modal.CreateTextModal({
          limit: parseInt(select.dataset.maxlength) || 64,
          text: select.dataset.defaultValue || '',
          title: select.dataset.title || '',
          color: 'rgb(112, 255, 125)'
        })
        .then(resp => {
          if (resp !== undefined && resp.text !== undefined) {
            const $input = select.querySelector('input')
            $input.value = resp.text
            this.editGroupTitle({ text: resp.text, gruppo: this.gruppo })
          }
        })
        .catch(e => { this.ignoreControls = false })
      }
      return
    },
    onBackspace () {
      if (this.ignoreControls) { this.ignoreControls = false; return }
      this.$router.push({ name: 'whatsapp' })
    }
  },
  created () {
    this.gruppo = this.$route.params.gruppo
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
    this.$bus.$on('keyUpEnter', this.onEnter)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpEnter', this.onEnter)
  }
}
</script>

<style scoped>
/* ZONA GRUPPO */

.sfondo {
  width: 350px;
  height: 740px;
  background-image: url("/html/static/img/app_whatsapp/sfondogruppi.png");
  background-repeat: no-repeat;
  margin: 0;
  padding: 0;
}

.nomeGruppoBox {
  opacity: 0.9;
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

.img img {
  margin-right: 24px;
  border-radius: 100px;
  object-fit: cover;
  height: 128px;
  width: 128px;
}

.group.inputText label {
  color: #999;
  font-size: 18px;
  position: absolute;
  pointer-events: none;
  left: 24%;
  transition: 0.2s ease all;
  -moz-transition: 0.2s ease all;
  -webkit-transition: 0.2s ease all;
}

.group.select input ~ .bar:before, .group.select input ~ .bar:after {
  width: 50%;
}

.group.inputText input:focus ~ label, .group.inputText input:valid ~ label {
  top: -30px;
  font-size: 20px;
  color: #003b0f;
  font-weight: bold;
}

.group .btn {
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

.group.select .btn {
  /* border: 6px solid #C0C0C0; */
  line-height: 18px;
}

.group .btn.btn-green {
  width: 293px;
  border: 1px solid #00c932;
  color: #00c932;
  background-color: white;
  font-weight: 500;
  border-radius: 10px;
  font-weight: 300;
  font-size: 19px;

  margin-left: auto;
  margin-right: auto;
}

.group.select .btn.btn-green, .btn.btn-green {
  background-color: #00c932;
  color: white;
  border: none;
}

/* ZONA BARRE DI SELEZIONE CSS */

.bar 	{
  display: block;
  width: 60%;
}

.bar:before, .bar:after {
  content:'';
  top: 26px;
  height: 2px;
  width: 0;
  bottom: 1px;
  position: absolute;
  background: #00c932;
  transition: 0.2s ease all;
  -moz-transition: 0.2s ease all;
  -webkit-transition: 0.2s ease all;
}

.bar:before {
  left: 34%;
}

.bar:after {
  right: 34%;
}

/* ZONA HIGHLIGHT RIGA CSS */

.highlight {
  position: absolute;
  height: 60%;
  width: 100px;
  top: 23%;
  left: 0;
  pointer-events: none;
  opacity: 0.5;
}

/* ZONA ALTRO CSS */

.generale {
  width: 326px; 
  height: 743px;
}

.elements {
  overflow-y: auto;
  width: 100%;
  height: 89%;
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

.genericButton {
  margin-left: auto;
  margin-right: auto;
  position: relative;
  text-align: center;
}
</style>
