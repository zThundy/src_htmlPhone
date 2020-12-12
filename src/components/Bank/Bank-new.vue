<template>
  <div class="phone_app">
    <PhoneTitle :title="IntlString('APP_BANK_TITLE')" v-on:back="onBackspace" backgroundColor="rgb(253, 148, 62)" />

    <div class="slice"></div>
    <div class="slice2"></div>

    <div class="dividerRectangle">
      <div class="md-example-child md-example-child-amount">
        <md-amount
          class="bankAmount"
          :value="bankAmount"
          :duration="1500"
          transition
        >
        </md-amount>$
      </div>
    </div>
    
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import PhoneTitle from '@/components/PhoneTitle'
import { Amount } from 'mand-mobile'
import 'mand-mobile/lib/mand-mobile.css'

export default {
  name: 'app_banca',
  components: {
    PhoneTitle,
    [Amount.name]: Amount
  },
  data () {
    return {
    }
  },
  computed: {
    ...mapGetters(['bankAmount', 'iban', 'IntlString'])
  },
  methods: {
    onBackspace () {
      this.$router.push({ name: 'home' })
    }
  },
  created () {
    this.$bus.$on('keyUpBackspace', this.onBackspace)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpBackspace', this.onBackspace)
  }
}
</script>

<style scoped>
.phone_app {
  background-color: rgb(36, 37, 41); 
}

.bankAmount {
  padding-left: 20px;
  padding-top: 150px;
}
























/* SLICE SOPRA E SOTTO */

.slice {
  position: absolute;
  padding: 2rem 20%;
}

.slice:nth-child(2) {
  top: 27px;
  background: rgb(253, 148, 62);
  color: white;
  clip-path: polygon(0 40%, 400% 50%, 100% 50%, 0 100%);
  padding: 3rem 70% 25%;
}

.slice2 {
  position: absolute;
  padding: 2rem 20%;
}

.slice2:nth-child(3) {
  bottom: 2px;
  background: rgb(253, 148, 62);
  color: white;
  clip-path: polygon(0 20%, 100% 80%, 40% 200%, 0 100%);
  padding: 3rem 70% 25%;
}
</style>
