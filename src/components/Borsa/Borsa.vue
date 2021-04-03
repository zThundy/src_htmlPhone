<template>
  <div class="phone_app">
    <PhoneTitle :title="LangString('APP_BOURSE_TITLE')" @back="onBackspace" :backgroundColor="'rgba(77, 100, 111, 1.0)'" />
    <div v-if="stocksProfile" class='container'>
      <div class="stocks-menu">
        <div class="stocks-menu-button selected"><i class="fas fa-chart-line stocks-menu-icon"></i>Mercato</div>
        <div class="stocks-menu-button"><i class="fas fa-business-time stocks-menu-icon"></i>Investimenti</div>
      </div>
      <img class="info-logo" src="https://icon-library.com/images/png-web-icon/png-web-icon-5.jpg" />
      <div class='profile-info'>
        <div class='info-user'>
          <p class='info-user-name'>{{ stocksProfile.name }}</p>
          <p class='info-user-surname'>{{ stocksProfile.surname }}</p>
        </div>
        <div class='info-balance'>
          <p class='info-balance-title'>Portafoglio</p>
          <p class='info-balance-amount'>{{ stocksProfile.balance }} $</p>
        </div>
      </div>
      <div v-if="stocksInfo" class="stocks-table">
        <div class="stocks-table-inner">
          <div v-for="(table, ticker) in stocksInfo" :key="ticker" class="stocks-table-elem" :class="{ select: currentSelect === ticker }">
            <p class="stocks-ticker stocks-bold">{{ table.fakeName }}</p>
            <p class="stocks-ticker stocks-current-mp">{{ table.currentMarket }} $</p>
            <p class="stocks-ticker stocks-current-variation" :style="{ color: getInfoColor(table) }">
              {{ table.currentMarket - table.closeMarket | truncate(1, " ") }}
              ({{ (Math.abs(table.currentMarket - table.closeMarket) * 100) / table.closeMarket | truncate(2, "%") }})
              <i class="stocks-ticker stocks-current-arrow fas"
                :class="getArrow(table)" :style="{ color: getInfoColor(table) }"
              ></i>
            </p>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import PhoneTitle from './../PhoneTitle'

export default {
  name: 'app-stocks',
  components: { PhoneTitle },
  data () {
    return {
      currentSelect: -1
    }
  },
  computed: {
    ...mapGetters(['LangString', 'stocksProfile', 'stocksInfo'])
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
    getInfoColor (item) {
      if (item.currentMarket - item.closeMarket > 0) {
        return '#4caf50'
      } else {
        return ' #f44336'
      }
    },
    getArrow (item) {
      if (item.currentMarket - item.closeMarket > 0) {
        return 'fa-arrow-up'
      } else {
        return 'fa-arrow-down'
      }
    },
    onBackspace () {
      this.$router.push({ name: 'menu' })
    },
    onUp () {
      this.currentSelect = this.currentSelect === 0 ? 0 : this.currentSelect - 1
      this.scrollIntoView()
    },
    onDown () {
      this.currentSelect = this.currentSelect === this.stocksInfo.length - 1 ? this.currentSelect : this.currentSelect + 1
      console.log(this.currentSelect)
      this.scrollIntoView()
    }
  },
  created () {
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
  }
}
</script>

<style scoped>
.container {
  height: 100%;
  background-color: rgb(197, 197, 197);
}

.stocks-menu {
  position: absolute;
  width: 100%;
  height: 70px;
  background-color: #607d8b;
  bottom: 0;
  z-index: 1;
  display: flex;
  justify-content: space-around;
  color: rgb(228, 228, 228);
}

.stocks-menu-button {
  background-color: #81949c;
  height: 45px;
  padding: 10px;
  margin-top: 8px;
  border-radius: 20px;
}

.stocks-menu-icon {
  margin-right: 5px;
}

.profile-info {
  background-color: #00394a;
  height: 130px;
  clip-path: polygon(0 0, 0 100px, 100% 100%, 100% 0);
  z-index: 99;
  display: flex;
  justify-content: space-around;
  color: white;
}

.info-user {
  position: relative;
  top: 20px;
}

.info-user-surname {
  font-weight: bold;
  font-size: 24px;
}

.info-balance {
  position: relative;
  top: 20px;
}

.info-balance-title {
  font-weight: bold;
  font-size: 24px;
}

.info-logo {
  position: absolute;
  right: 40px;
  top: 165px;
  width: 80px;
  z-index: 9999;
}

.stocks-table {
  background-color: #001e27;
  margin-top: -30px;
  height: 85%;
}

.stocks-table-inner {
  top: 70px;
  position: relative;
  height: 438px;
  overflow-y: auto;
}

.stocks-table-elem {
  background-color: #00394a;
  height: 70px;
  border-bottom: 1px solid #607d8b;
  display: flex;
  justify-content: space-between;
}

.stocks-table-elem.select {
  background-color: #005c79;
}

.stocks-ticker {
  position: relative;
  top: 20px;
  margin-left: 10px;
  color: #69a7c3;
}

.stocks-bold {
  font-weight: bold;
  left: 5px;
}

.stocks-current-mp {
  color: white;
}

.stocks-current-variation {
  top: 22px;
  font-size: 16px;
  color: #991616;
  font-weight: bold;
}

.stocks-current-arrow {
  top: 0;
  left: -10px;
  font-size: 14px;
}
</style>
