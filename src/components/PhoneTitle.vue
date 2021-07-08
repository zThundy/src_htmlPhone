<template>
  <div :style="style" :class="{ 'showSegnaleSection': showSegnaleSection }" >
    <InfoBare v-if="showSegnaleSection" />
    
    <div class="phone_title" :style="{ backgroundColor: backgroundColor }">
      <i :style="{ color: color }" class="fas fa-angle-left"/>
      <span :style="{ color: color }">{{ title }}</span>
    </div>
  
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import InfoBare from './InfoBare'

export default {
  components: { InfoBare },
  computed: {
    ...mapGetters([]),
    style () {
      return {
        backgroundColor: this.backgroundColor
      }
    }
  },
  methods: { },
  props: {
    title: {
      type: String,
      required: true
    },
    showSegnaleSection: {
      type: Boolean,
      default: true
    },
    backgroundColor: {
      type: String,
      default: 'rgb(240, 240, 240)'
    },
    color: {
      type: String,
      default: 'black'
    }
  }
}
</script>

<style scoped>

.phone_title {
  font-family: SanFrancisco;
  position: relative;

  display: flex;
  flex-direction: row;
  /* font-weight: 300; */
  /* font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; */

  margin-top: 6px;

  height: 55px;
  width: 100%;
  /* height: 64px; */
  /* line-height: 10px; */
  /* font-size: 28px; */
  border-bottom: 1px solid #838383;
}

.phone_title i {
  margin-top: auto;
  margin-bottom: auto;
  margin-left: 20px;
}

.phone_title span {
  margin-top: auto;
  margin-bottom: auto;
  margin-left: 15px;
  max-width: 80%;
}
</style>
