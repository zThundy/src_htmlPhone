<template>
  <div style="width: auto; top: 4px;" class='phone_infoBare barre-header'>
    <span class='reseau'>{{config.reseau}}</span>
    <span class="time">
      <current-time style="font-size: 12px; margin-right: 2px;"></current-time>
    </span>

    <div v-if="hasWifi && isWifiOn" class="wifi-image">
      <img src="/html/static/img/app_dati/wifion.png" style="height: 14px; width: 14px;">
    </div>

    <div v-else-if="!hasWifi || !isWifiOn" class="wifi-image">
      <img src="/html/static/img/app_dati/wifioff.png" style="height: 14px; width: 14px;">
    </div>
    
    <div class="bars">
      <hr v-if="updateBars()" :style="barra1">
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
    ...mapGetters(['config', 'segnale', 'hasWifi'])
  },
  components: { CurrentTime },
  data: function () {
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
  height: 24px;
  font-size: 17px;
  line-height: 24px;
  padding: 0px 20px 0px 24px;
  width: 100%;
  color: white;
  background-color: rgba(0, 0, 0, 0.3);
  position: relative;
}

.wifi-image {
  left: 204px;
  bottom: 24px;
  background-color: rgba(0, 0, 0, 0);
  /* border: none; */
  position: relative;
}

.barre-header hr {
  position: absolute;
  display: inline-block;
}

.reseau {
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
