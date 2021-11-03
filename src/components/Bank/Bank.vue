<template>
  <div class="phone_app">
    <PhoneTitle :title="LangString('APP_BANK_TITLE')" :back="onBackspace" :color="'white'" :backgroundColor="'rgb(45, 74, 175)'" />

    <div class="slice"></div>
    <div class="slice2"></div>

    <div class="dividerRectangle md-example-child md-example-child-amount">
      <i class="fas fa-credit-card"></i>
      <md-amount class="bankAmount" :value="bankAmount" :duration="1500" has-separator transition></md-amount> $
    </div>

    <div class="dividerRectangle2">
      <i class="fas fa-id-card"></i>
      <span class="bankAmount">{{ iban }}</span>
    </div>

    <hr class="separator">

    <div class="movementsCards">

      <div class="movementsCard" v-for="(elem, key) in movements" :key="key" v-bind:class="{selected: key === currentSelect}">
        <i v-if="elem.type == 'positive'" style="color: lime;" class="fas fa-arrow-up"></i>
        <i v-else style="color: red;" class="fas fa-arrow-down"></i>
        <label class="to">{{ LangString('APP_BANK_MOVEMENTS_TO') }}: {{ elem.to }}</label>
        <label class="from">{{ LangString('APP_BANK_MOVEMENTS_FROM') }}: {{ elem.from }}</label>
        <label class="amount">{{ LangString('APP_BANK_MOVEMENTS_AMOUNT') }}: {{ elem.amount }} $</label>
        <hr class="mov-separator">
      </div>

    </div>
    
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import PhoneTitle from '@/components/PhoneTitle'
import { Amount } from 'mand-mobile'
import 'mand-mobile/lib/mand-mobile.css'
import Modal from '@/components/Modal/index.js'

export default {
  name: 'app_banca',
  components: { PhoneTitle, [Amount.name]: Amount },
  data () {
    return {
      ignoreControls: false,
      currentSelect: -1
    }
  },
  computed: {
    ...mapGetters(['bankAmount', 'iban', 'LangString', 'fatture', 'movements'])
  },
  methods: {
    scrollIntoView: function () {
      this.$nextTick(() => {
        document.querySelector('.selected').scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' })
      })
    },
    onBackspace () {
      if (this.ignoreControls) { this.ignoreControls = false; return }
      if (this.currentSelect !== -1) { this.currentSelect = -1; return }
      this.$router.push({ name: 'menu' })
    },
    onRight () {
      if (this.ignoreControls) return
      this.ignoreControls = true
      Modal.CreateModal({ scelte: [
        {id: 1, title: this.LangString('APP_BANK_LISTA_FATTURE'), icons: 'fa-list-alt'},
        {id: 2, title: this.LangString('APP_BANK_CREATE_MOVEMENT'), icons: 'fa-plus'},
        {id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red'}
      ] })
      .then(response => {
        switch(response.id) {
          case 1:
            this.listaFatture()
            break
          case 2:
            Modal.CreateTextModal({
              limit: 200,
              title: this.LangString('APP_BANK_TYPE_IBAN_TITLE'),
              color: 'rgb(45, 74, 175)'
            })
            .then(iban => {
              Modal.CreateTextModal({
                limit: 200,
                title: this.LangString('APP_BANK_TYPE_AMOUNT_TITLE'),
                color: 'rgb(45, 74, 175)'
              })
              .then(amount => {
                this.$phoneAPI.postUpdateMoney(Number(amount.text), iban.text.toUpperCase())
                this.ignoreControls = false
              })
              .catch(e => { this.ignoreControls = false })
            })
            .catch(e => { this.ignoreControls = false })
            break
          case -1:
            this.ignoreControls = false
            break
        }
      })
      .catch(e => { this.ignoreControls = false })
    },
    onUp () {
      if (this.ignoreControls) return
      if (this.currentSelect === 0) return
      this.currentSelect = this.currentSelect - 1
      this.scrollIntoView()
    },
    onDown () {
      if (this.ignoreControls) return
      if (this.currentSelect === this.movements.length - 1) return
      this.currentSelect = this.currentSelect + 1
      this.scrollIntoView()
    },
    async listaFatture () {
      this.ignoreControls = true
      try {
        var scelte = []
        for (var key in this.fatture) { scelte.push({ id: this.fatture[key].id, title: this.fatture[key].label + ' - ' + this.fatture[key].amount, icons: 'fa-dollar-sign', fattura: this.fatture[key] }) }
        scelte.push({ id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' })
        // dopo essermi creato la lista delle fatture, mi buildo il menù
        Modal.CreateModal({ scelte })
        .then(resp => {
          switch(resp.id) {
            case -1:
              this.ignoreControls = false
              break
            default:
              this.selectedFatturaOptions(resp.fattura)
          }
        })
        .catch(e => { this.ignoreControls = false })
      } catch (e) { }
    },
    selectedFatturaOptions (fattura) {
      this.ignoreControls = true
      Modal.CreateModal({ scelte: [
        {id: 1, title: this.LangString('APP_BANK_MODAL_PAGA_FATTURE'), icons: 'fa-check-square'},
        {id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red'}
      ] })
      .then(resp => {
        if (resp.id === 1) {
          this.$phoneAPI.pagaFattura(fattura)
          setTimeout(() => {
            this.ignoreControls = false
          }, 5000)
        }
      })
      .catch(e => { this.ignoreControls = false })
    }
  },
  created () {
    this.$phoneAPI.requestBankInfo()
    this.$phoneAPI.requestFatture()
    this.$bus.$on('keyUpBackspace', this.onBackspace)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
  }
}
</script>

<style scoped>
.phone_app {
  background-color: rgb(36, 37, 41); 
}

.bankAmount {
  position: relative;
  font-weight: bold;
}

.dividerRectangle {
  top: 140px;
  left: 10px;
  text-align: right;
  background-color: rgb(65, 65, 65);
  border-radius: 25px;
  width: 94%;
  height: 5%;
  position: sticky;
  font-weight: 500;

  -moz-box-shadow: 0 0 5px 5px rgb(55, 55, 55);
  -webkit-box-shadow: 0 0 5px 5px rgb(55, 55, 55);
  box-shadow: 0 0 5px 5px rgb(55, 55, 55);

  padding-top: 5px;
  padding-right: 20px;
  color: rgb(156, 156, 156);
}

.dividerRectangle2 {
  top: 200px;
  left: 10px;
  text-align: right;
  background-color: rgb(65, 65, 65);
  border-radius: 25px;
  width: 94%;
  height: 5%;
  position: sticky;
  font-weight: 500;

  -moz-box-shadow: 0 0 5px 5px rgb(55, 55, 55);
  -webkit-box-shadow: 0 0 5px 5px rgb(55, 55, 55);
  box-shadow: 0 0 5px 5px rgb(55, 55, 55);

  padding-top: 5px;
  padding-right: 20px;
  color: rgb(156, 156, 156);
}

i {
  position: absolute;
  left: 15px;
  padding-top: 4px;
  color: rgb(156, 156, 156);
}

.separator {
  position: absolute;
  top: 260px;
  left: 15px;

  border-radius: 10px;
  border: 1px solid rgb(94, 94, 94);
  width: 91%;
}

.movementsCards {
  position: relative;
  margin: 10px;
  top: 115px;
  width: 100%;
  height: 42%;
  overflow-y: auto;
}

.movementsCard {
  padding-top: 5px;
  background-color: rgb(65, 65, 65);
  border-radius: 15px;
  margin-top: 10px;
  width: 94%;
  height: 65px;

  color: rgb(156, 156, 156);
}

.movementsCard .from {
  position: absolute;
  justify-content: left;
  text-align: left;
  font-weight: 400;
  font-size: 16px;
  padding-top: 2px;
  left: 42px;
}

.movementsCard .to {
  justify-content: right;
  text-align: right;
  position: absolute;
  font-weight: 400;
  font-size: 16px;
  padding-top: 2px;
  right: 50px;
}

.movementsCard .amount {
  justify-content: center;
  text-align: center;
  position: absolute;
  font-weight: 400;
  font-size: 16px;
  left: 105px;
  padding-top: 34px;
}

.movementsCard .mov-separator {
  position: relative;
  top: 20px;

  border-radius: 10px;
  border: 1px solid rgb(156, 156, 156);
  width: 75%;
  left: 5px;
}

.movementsCard.selected {
  background-color: rgb(94, 94, 94);
}










/* SLICE SOPRA E SOTTO */

.slice {
  position: absolute;
  padding: 2rem 20%;
}

.slice:nth-child(2) {
  top: 2px;
  background: rgb(45, 74, 175);
  color: white;
  clip-path: polygon(0% 0%, 0% 55%, 200% 40%, 0 90%);
  padding: 3rem 70% 25%;
}

.slice2 {
  position: absolute;
  padding: 2rem 20%;
}

.slice2:nth-child(3) {
  bottom: 2px;
  background: rgb(45, 74, 175);
  color: white;
  clip-path: polygon(0 20%, 100% 80%, 40% 200%, 0 100%);
  padding: 3rem 70% 25%;
}
</style>
