<template>
  <div class='barre-header'>
    <span class='operator_title'>{{ config.operator_title }}</span>
    <span class="time">
      <current-time style="font-size: 12px; margin-right: 2px;"></current-time>
    </span>

    <div v-if="hasWifi && isWifiOn" class="wifi-image">
      <img src="/html/static/img/app_dati/wifion.png" style="height: 14px; width: 14px;">
    </div>

    <div v-else-if="!hasWifi || !isWifiOn" class="wifi-image">
      <img src="/html/static/img/app_dati/wifioff.png" style="height: 14px; width: 14px;">
    </div>
    
    <div v-if="updateBars()" class="bars">
      <hr :style="barra1">
      <hr :style="barra2">
      <hr :style="barra3">
      <hr :style="barra4">
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import CurrentTime from './CurrentTime'

export default {
  computed: {
    ...mapGetters(['config', 'segnale', 'hasWifi', 'isWifiOn'])
  },
  components: { CurrentTime },
  data () {
    return {
      barra1: {
        height: '12px',
        width: '3px',
        right: '5px',
        'background-color': 'rgba(128, 128, 128, 150)',
        border: 'none',
        bottom: '-3px'
      },
      barra2: {
        height: '10px',
        width: '3px',
        right: '10px',
        'background-color': 'rgba(128, 128, 128, 150)',
        border: 'none',
        bottom: '-3px'
      },
      barra3: {
        height: '8px',
        width: '3px',
        right: '15px',
        'background-color': 'rgba(128, 128, 128, 150)',
        border: 'none',
        bottom: '-3px'
      },
      barra4: {
        height: '6px',
        width: '3px',
        right: '20px',
        'background-color': 'rgba(128, 128, 128, 150)',
        border: 'none',
        bottom: '-3px'
      }
    }
  },
  methods: {
    updateBars () {
      this.barra4['background-color'] = this.segnale > 0 ? 'rgba(255, 255, 255, 150)' : 'rgba(128, 128, 128, 150)'
      this.barra3['background-color'] = this.segnale > 1 ? 'rgba(255, 255, 255, 150)' : 'rgba(128, 128, 128, 150)'
      this.barra2['background-color'] = this.segnale > 2 ? 'rgba(255, 255, 255, 150)' : 'rgba(128, 128, 128, 150)'
      this.barra1['background-color'] = this.segnale > 3 ? 'rgba(255, 255, 255, 150)' : 'rgba(128, 128, 128, 150)'
      return true
    }
  }
}
</script>

<style scoped>
.barre-header {
  width: 100%;
  height: 24px;
  font-size: 17px;
  top: 3px;
  line-height: 24px;
  padding: 0px 20px 0px 24px;
  color: white;
  background-color: rgba(0, 0, 0, 0.3);
  position: relative;
}

.wifi-image {
  /* left: 204px; */
  /* bottom: 24px; */
  /* background-color: rgba(0, 0, 0, 0); */
  /* border: none; */
  position: relative;
  float: right;
  right: 35px;
  top: 2px;
}

.barre-header hr {
  position: absolute;
  display: inline-block;
}

.operator_title {
  font-size: 12px;
}

.bars {
  position: absolute;
  right: 55px;
  bottom: 0;
}

.time {
  text-align: right;
  float: right;
  margin-right: -14px;
  font-size: 12px;
  padding-right: 12px;
}
</style>
