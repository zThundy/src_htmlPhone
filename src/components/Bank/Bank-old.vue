<template>
  <div style="width: 326px; height: 765px;" class="screen">
    
    <div class='elements'>
      <InfoBare style="width: 326px;top: -207px; margin-left: -17px;"/>
      <img class="logo_maze" src="/html/static/img/app_bank/fleeca_tar.png">
      <div class="money-div" >
        <span class="moneyTitle">{{ LangString('APP_BANK_TITLE_BALANCE') }}:</span>
        <md-amount class="moneyTitle" :value="bankAmount" :duration="2500" transition has-separator></md-amount>$
        <!-- <span class="moneyTitle">{{ bankAmount }}$</span> -->
      </div>

      <div class="iban">
        <span class="ibanTitle">{{ LangString('APP_BANK_TITLE_IBAN') }}:</span>
        <span class="ibanTitle">{{ iban }}</span>
      </div>
      
      <div class="hr"></div>
      
      <div class='element'>
        <div class="element-content">
          
        </div>

        <div class="element-content" ref="form"> 
          <input style=" border-radius: 23px; font-size: 16px;" v-bind:class="{ select: 0 === currentSelect}" v-autofocus oninput="this.value = this.value.toUpperCase();" ref="form0" v-model="id" class="paragonder" placeholder="IBAN">
        </div> 

        <div class="element-content">           
          <input style=" border-radius: 23px; font-size: 16px;" v-bind:class="{ select: 1 === currentSelect}" oninput="this.value = this.value.replace(/[^0-9.]/g, ''); this.value = this.value.replace(/(\..*)\./g, '$1'); this.value = this.value + '$'" ref="form1" v-model="soldi" class="paragonder" placeholder="$">
          <button v-bind:class="{ select: 2 === currentSelect}" ref="form2" id="gonder" class="buton-transfer">{{ LangString('APP_BANK_BUTTON_TRANSFER') }}</button><br/>
          <button v-bind:class="{ select: 3 === currentSelect}" ref="form3" id="cancella" class="buton-cancel">{{ LangString('APP_BANK_BUTTON_CANCEL') }}</button>
        </div>
        
      </div>
      
    </div>
    <img class="logo_tarj_end" src="/html/static/img/app_bank/tarjetas.png">
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import InfoBare from '../InfoBare'
import { Amount } from 'mand-mobile'

export default {
  components: {
    InfoBare,
    [Amount.name]: Amount
  },
  data () {
    return {
      id: '',
      soldi: '',
      currentSelect: 0
    }
  },
  computed: {
    ...mapGetters(['bankAmount', 'iban', 'LangString'])
  },
  methods: {
    ...mapActions(['inviaSoldiAPI']),
    scrollIntoViewIfNeeded: function () {
      this.$nextTick(() => {
        document.querySelector('focus').scrollIntoViewIfNeeded()
      })
    },
    onBackspace () {
      this.$router.push({ name: 'menu' })
    },
    cancella () {
      // this.$router.push({path: '/messages'})
      this.$router.push({ name: 'menu' })
    },
    inviaSoldi () {
      const soldi = this.soldi.substring(1, this.soldi.length).trim()
      if (soldi === '') return
      this.soldi = ''
      this.inviaSoldiAPI({
        money: soldi,
        iban: this.id
      })
    },
    onUp: function () {
      if ((this.currentSelect - 1) >= 0) {
        this.currentSelect = this.currentSelect - 1
      }
      this.$refs['form' + this.currentSelect].focus()
    },
    onDown () {
      if ((this.currentSelect + 1) <= 3) {
        this.currentSelect = this.currentSelect + 1
      }
      this.$refs['form' + this.currentSelect].focus()
    },
    onEnter () {
      if (this.ignoreControls === true) return
      if (this.currentSelect === 2) {
        this.inviaSoldi()
      } else if (this.currentSelect === 0) {
        this.$phoneAPI.getReponseText().then(data => {
          let message = data.text.trim()
          this.id = message.toUpperCase()
        })
      } else if (this.currentSelect === 1) {
        this.$phoneAPI.getReponseText().then(data => {
          let message = data.text.trim()
          this.soldi = '$' + message
        })
      } else if (this.currentSelect === 3) {
        this.cancella()
      }
    }
  },
  created () {
    this.$phoneAPI.requestBankInfo()
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
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
  padding: 18px;
  background-color: white;
}

.money-div {
  margin-top: -88px; 
  margin-left: 40px;
  color: white;
  font-size: 16px;
}

.moneyTitle {
  font-weight: 200;
  color: white;
  font-size: 16px;
}

.iban {
 margin-left: 40px
}

.ibanTitle {
  font-weight: 200;
  color: white;
  font-size: 16px;
}

.title {
  padding-left: 16px;
  height: 34px;
  line-height: 34px;
  font-weight: 700;
  color: white;
  background-color: rgb(76, 175, 80);
}

.elements {
  display: flex;
  position: relative;
  width: 100%;
  flex-direction: column;
  height: 100%;
  justify-content: center;
}

.hr {
  width: 100;
  height: 4px;
  margin-top: 73px;
  background-image: linear-gradient(to right, #a9cc2e, #7cb732, #3a5d0d);  
}

.logo_maze {
  width: 100%; 
  height: auto;
  flex-shrink: 0;
  
  width: 113%;
  margin-left: -18px;
  margin-top: -207px
}

.logo_tarj_end {
  width: 100%; 
  height: auto;
  flex-shrink: 0;
  
  width: 113%;
  margin-left: -18px;
  margin-top: -77px
}

.element-content {
  margin-top: 24px;
  display: block; 
  width: 100%;
  text-align: center;
  font-weight: 700;
  font-size: 24px;
  color: black;
  
}
.paragonder {
  display: block;
      
  width: 100%;
  height: calc(1.5em + .75rem + 2px);
  padding: .375rem .75rem;
  font-size: 1rem;
  font-weight: 300;
  line-height: 1.5;
  color: #495057;
  background-color: #fff;
  background-clip: padding-box;
  border: 1px solid #ced4da;
  border-radius: .25rem;
  transition: border-color .15s ease-in-out, box-shadow .15s ease-in-out;
}
.buton-transfer {
  border: none;
  width: 220px;
  color: #fff;
  background-image: linear-gradient(to right, #a9cc2e, #7cb732, #3a5d0d); 
  padding: .5rem 1rem;
  font-size: 17px;
  line-height: 1.5;
  margin-top: 1.25rem;
  font-weight: 300;
  margin-bottom: .25rem;
  cursor: pointer;
  border-radius: 1.3rem;
  transition: color .15s ease-in-out, background-color .15s ease-in-out, border-color .15s ease-in-out, box-shadow .15s ease-in-out;
  text-transform: none;
}

.buton-cancel {
  border: none;
  width: 220px;
  color: #fff;
  background-image: linear-gradient(to right, #747474, #747474 , #5f5f5f); 
  padding: .5rem 1rem;
  font-size: 17px;
  line-height: 1.5;
  margin-top: 1.25rem;
  font-weight: 300;
  margin-bottom: .25rem;
  cursor: pointer;
  border-radius: 1.3rem;
  transition: color .15s ease-in-out, background-color .15s ease-in-out, border-color .15s ease-in-out, box-shadow .15s ease-in-out;
  text-transform: none;
}

.select {
  overflow: auto;
  border: 3px solid #7cb732;
}
</style>
