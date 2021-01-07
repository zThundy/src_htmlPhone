<template>
  <div class="phone_title_content" :style="style" :class="{ 'showSegnaleSection': showSegnaleSection }" >
    <InfoBare v-if="showSegnaleSection" />
    
    <div class="phone_title" :style="{ backgroundColor: backgroundColor }">
      <div :style="{ color: color }" class="title">{{ title }}</div>
      
      <i :style="{ color: color }" class="backIcon fas fa-angle-left"/>
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
  methods: {
    back () {
      this.$emit('back')
    }
  },
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
      type: String
    },
    showSlice: {
      type: Boolean,
      default: false
    },
    color: {
      type: String,
      default: 'black'
    }
  }
}
</script>
<style scoped>
.title {
  font-family: SanFrancisco;
  font-weight: 500;

  padding-top: 20px;
  padding-right: 10px;
  text-align: center;
  position: relative;
}

.btn-back {
  color: black;
}

.backIcon {
  position: absolute;
  left: 28px;
  margin: auto;
  top: 24px;
}

.btn-back:hover {
  background-color: rgba(0, 0, 0, 0);
}
</style>
