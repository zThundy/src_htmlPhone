<template>
  <div class="phone_app">
    <PhoneTitle :title="LangString('APP_BOURSE_TITLE')" @back="onBackspace" :backgroundColor="'rgba(77, 100, 111, 1.0)'" />

    <div v-if="stocksProfile" class='bourse_container'>
      <div class="bourse-stocks-menu">
        <div class="bourse-stocks-menu-button" :class="{ selected: currentPage === 0 }"><i class="fas fa-chart-line bourse-stocks-menu-icon"></i>Mercato</div>
        <div class="bourse-stocks-menu-button" :class="{ selected: currentPage === 1 }"><i class="fas fa-business-time bourse-stocks-menu-icon"></i>Investimenti</div>
      </div>

      <div v-if="currentPage === 0">
        <img class="bourse-info-logo" src="/html/static/img/icons_app/borsa.png" />
        <div class='bourse-profile-bourse-info'>
          <div class='bourse-info-user'>
            <p class='bourse-info-user-name'>{{ stocksProfile.name }}</p>
            <p class='bourse-info-user-surname'>{{ stocksProfile.surname }}</p>
          </div>
          <div class='bourse-info-balance'>
            <p class='bourse-info-balance-title'>Portafoglio</p>
            <md-amount class="bourse-info-balance-amount" :value="stocksProfile.balance" :duration="500" has-separator transition></md-amount> $
          </div>
        </div>

        <div class="bourse-stocks-table">
          <div class="bourse-stocks-table-inner">
            <div v-for="(table, key) in stocksInfo" :key="key" class="bourse-stocks-table-elem" :class="{ select: currentSelect === key }">
              <p class="bourse-stocks-ticker bourse-stocks-bold">{{ table.name }}</p>
              <p class="bourse-stocks-ticker bourse-stocks-current-mp">{{ table.currentMarket }} $</p>
              <p class="bourse-stocks-ticker bourse-stocks-current-variation" :style="{ color: getBourseColor(table) }">
                {{ Number(table.currentMarket - table.closeMarket).toFixed(1) }}
                ({{ Number((Math.abs(table.currentMarket - table.closeMarket) * 100) / table.closeMarket).toFixed(2) }}%)
                <i class="bourse-stocks-ticker bourse-stocks-current-arrow"
                  :class="getBourseArrow(table)" :style="{ color: getBourseColor(table) }"
                ></i>
              </p>
            </div>
          </div>
        </div>
      </div>

      <div v-if="currentPage === 1">
        <img class="bourse-info-logo" src="/html/static/img/icons_app/borsa.png" />

        <div class='bourse-profile-bourse-info'>
          <div class='bourse-info-user'>
            <p class='bourse-info-user-name'>{{ stocksProfile.name }}</p>
            <p class='bourse-info-user-surname'>{{ stocksProfile.surname }}</p>
          </div>
          <div class='bourse-info-balance'>
            <p class='bourse-info-balance-title'>Portafoglio</p>
            <md-amount class="bourse-info-balance-amount" :value="stocksProfile.balance" :duration="500" has-separator transition></md-amount> $
          </div>
        </div>
        
        <div class="bourse-stocks-table">
          <div class="bourse-stocks-table-inner">
            <div v-for="(table, key) in myStocksInfo" :key="key" class="bourse-stocks-table-elem" :class="{ select: currentSelect === key }">
              <p class="bourse-stocks-ticker-personal bourse-stocks-bold">{{ table.name }}</p>
              <p class="bourse-stocks-ticker-personal bourse-stocks-current-mp">{{ table.amount }}</p>
              <p class="bourse-stocks-ticker-personal bourse-stocks-current-mp">{{ getCurrentMarket(table).toFixed(1) }} $</p>
              <p class="bourse-stocks-ticker-personal bourse-stocks-current-mp">{{ (getCurrentMarket(table) * table.amount).toFixed(1) }} $</p>
            </div>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import PhoneTitle from './../PhoneTitle'
import Modal from '@/components/Modal/index.js'

import { Amount } from 'mand-mobile'
import 'mand-mobile/lib/mand-mobile.css'

export default {
  name: 'borsa',
  components: {
    PhoneTitle,
    [Amount.name]: Amount
  },
  data () {
    return {
      currentSelect: -1,
      currentPage: 0,
      ignoreControls: false
    }
  },
  computed: {
    ...mapGetters(['LangString', 'stocksInfo', 'stocksProfile', 'myStocksInfo'])
  },
  methods: {
    scrollIntoView () {
      this.$nextTick(() => {
        const elem = this.$el.querySelector('.select')
        if (elem !== null) {
          elem.scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' })
        }
      })
    },
    onBackspace () {
      if (this.ignoreControls) {
        this.ignoreControls = false
        return
      }
      if (this.currentPage === 1) {
        this.currentPage = 0
        return
      }
      this.$router.push({ name: 'menu' })
    },
    onUp () {
      if (this.ignoreControls) return
      this.currentSelect = this.currentSelect === 0 ? 0 : this.currentSelect - 1
      this.scrollIntoView()
    },
    onDown () {
      if (this.ignoreControls) return
      // console.log(JSON.stringify(this.stocksInfo))
      // console.log(this.stocksInfo.length)
      // console.log(this.stocksInfo)
      this.currentSelect = this.currentSelect === this.stocksInfo.length - 1 ? this.currentSelect : this.currentSelect + 1
      this.scrollIntoView()
    },
    onLeft () {
      if (this.ignoreControls) return
      if (this.currentPage === 0) return
      this.currentPage -= 1
      this.currentSelect = -1
    },
    onRight () {
      if (this.ignoreControls) return
      if (this.currentPage === 1) return
      this.currentPage += 1
      this.currentSelect = -1
    },
    onEnter () {
      if (this.currentSelect === -1) return
      if (this.ignoreControls) return
      if (this.currentPage === 0) {
        this.ignoreControls = true
        Modal.CreateModal({ scelte: [
          { id: 1, title: this.LangString('APP_BOURSE_CHOICE_BUY'), icons: 'fa-dollar-sign', color: 'green' },
          { id: 2, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' }
        ] })
        .then(response => {
          switch(response.id) {
            case 1:
              Modal.CreateTextModal({
                limit: 5,
                text: '1',
                title: this.LangString('APP_BOURSE_BUY_TITLE'),
                color: 'rgb(77, 100, 111)'
              })
              .then(resp => {
                if (resp && resp.text && !isNaN(Number(resp.text))) {
                  this.$phoneAPI.buyCrypto({ amount: Number(resp.text), crypto: this.stocksInfo[this.currentSelect] })
                }
                this.ignoreControls = false
              })
              .catch(e => { this.ignoreControls = false })
              break
            case 2:
              this.ignoreControls = false
              break
          }
        })
        .catch(e => { this.ignoreControls = false })
      } else {
        this.ignoreControls = true
        Modal.CreateModal({ scelte: [
          { id: 1, title: this.LangString('APP_BOURSE_CHOICE_SELL'), icons: 'fa-dollar-sign', color: '#ff5f13' },
          { id: 2, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' }
        ] })
        .then(response => {
          switch(response.id) {
            case 1:
              Modal.CreateTextModal({
                limit: 5,
                text: '1',
                title: this.LangString('APP_BOURSE_SELL_TITLE'),
                color: 'rgb(77, 100, 111)'
              })
              .then(resp => {
                if (resp && resp.text && !isNaN(Number(resp.text))) {
                  this.$phoneAPI.sellCrypto({ amount: Number(resp.text), crypto: this.myStocksInfo[this.currentSelect], price: this.getCurrentMarket(this.myStocksInfo[this.currentSelect]) })
                }
                this.ignoreControls = false
              })
              .catch(e => { this.ignoreControls = false })
              break
            case 2:
              this.ignoreControls = false
              break
          }
        })
        .catch(e => { this.ignoreControls = false })
      }
    },
    getBourseColor (tb) {
      if (tb.currentMarket - tb.closeMarket === 0) {
        return '#00ffff'
      } else if (tb.currentMarket - tb.closeMarket > 0) {
        return '#4caf50'
      } else {
        return ' #f44336'
      }
    },
    getBourseArrow (tb) {
      if (tb.currentMarket - tb.closeMarket === 0) {
        return 'fas fa-arrow-right'
      } else if (tb.currentMarket - tb.closeMarket > 0) {
        return 'fas fa-arrow-up'
      } else {
        return 'fas fa-arrow-down'
      }
    },
    getCurrentMarket (tb) {
      if (tb && tb.name) {
        for (var id in this.stocksInfo) {
          if (this.stocksInfo[id].name === tb.name) {
            return this.stocksInfo[id].currentMarket
          }
        }
      }
      return 0
    }
  },
  created () {
    this.$phoneAPI.requestBourseProfile()

    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
    this.$bus.$on('keyUpEnter', this.onEnter)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpEnter', this.onEnter)
  }
}
</script>

<style scoped>
.bourse_container {
  height: 100%;
  background-color: rgb(197, 197, 197);
}

.bourse-stocks-menu {
  position: absolute;
  width: 100%;
  height: 70px;
  background-color: #607d8b;
  bottom: 0;
  z-index: 1;
  display: flex;
  justify-content: space-around;
  color: rgb(15, 15, 15);
}

.bourse-stocks-menu-button {
  background-color: #96b2be;
  height: 45px;
  padding: 12px;
  margin-top: 10px;
  border-radius: 20px;
  font-size: 18px;
}

.bourse-stocks-menu-icon {
  margin-right: 5px;
}

.bourse-profile-bourse-info {
  background-color: #00394a;
  height: 130px;
  clip-path: polygon(0 0, 0 100px, 100% 100%, 100% 0);
  z-index: 99;
  display: flex;
  justify-content: space-around;
  color: white;
}

.bourse-info-user {
  position: relative;
  top: 20px;
}

.bourse-info-user-surname {
  font-weight: bold;
  font-size: 24px;
}

.bourse-info-balance {
  position: relative;
  top: 20px;
}

.bourse-info-balance-title {
  font-weight: bold;
  font-size: 24px;
}

.bourse-info-logo {
  position: absolute;
  right: 40px;
  top: 165px;
  width: 80px;
  z-index: 9999;
}

.bourse-stocks-table {
  background-color: #001e27;
  margin-top: -30px;
  height: 490px;
}

.bourse-stocks-table-inner {
  top: 70px;
  position: relative;
  height: 439px;
  overflow-y: hidden;
}

.bourse-stocks-table-elem {
  background-color: #00394a;
  height: 70px;
  border-bottom: 1px solid #607d8b;
  display: flex;
  justify-content: space-between;
}

.bourse-stocks-table-elem.select {
  background-color: #005c79;
}

.bourse-stocks-menu-button.selected {
  background-color: #00394a;
  color: white;
}

.bourse-stocks-ticker {
  position: relative;
  top: 22px;
  margin-left: 10px;
  color: #69a7c3;
}

.bourse-stocks-ticker-personal {
  position: relative;
  top: 22px;
  color: #69a7c3;
  margin-left: 5px;
  margin-right: 10px;
}

.bourse-stocks-bold {
  font-weight: bold;
  left: 5px;
}

.bourse-stocks-current-mp {
  color: white;
}

.bourse-stocks-current-variation {
  top: 22px;
  font-size: 16px;
  color: #991616;
  font-weight: bold;
}

.bourse-stocks-current-arrow {
  top: 0;
  left: -10px;
  font-size: 14px;
}
</style>
