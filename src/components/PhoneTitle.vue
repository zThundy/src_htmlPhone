<template>
  <div class="phone_title_content" :style="style" :class="{'hasInfoBare': showInfoBare}" >
    <InfoBare v-if="showInfoBare" />

    <div v-if="showSlice === true">
      <div class="slice" :style="{backgroundColor: backgroundColor, color: textColor}">
        <i style="padding-top: 15px; padding-right: 25px;" class="fas fa-angle-left" @click.stop="back"></i>
      </div>

      <div class="title">{{title}}</div>
    </div>

    <div v-else>
      <div class="phone_title" :style="{backgroundColor: backgroundColor, color: textColor}">
        <button class="btn-back" @click.stop="back">
          <i style="padding-top: 15px; padding-right: 25px;" class="fas fa-angle-left" @click.stop="back"></i>
        </button>

        <div class="title">{{title}}</div>
      </div>
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
        backgroundColor: this.backgroundColor,
        textColor: this.textColor,
        showSlice: this.showSlice
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
    showInfoBare: {
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
    textColor: {
      type: String,
      default: 'black'
    }
  }
}
</script>
<style scoped>
.title {
  padding-top: 5px;
  font-family: Arial, Helvetica, sans-serif;
  text-align: center;
  padding-right: 90px;
}

.phone_title {
  padding-top: 4px;
}

.btn-back {
  padding-top: 4px;
}

.phone_title_content {
  font-size: 10px;
}

.slice {
  position: absolute;
  padding: 2rem 20%;
}

.slice:nth-child(2) {
  top: 27px;
  background: rgba(255, 164, 103, 0.541);
  color: white;
  clip-path: polygon(0 0, 100% 0, 100% 20%, 0 100%);
  padding: 3rem 70% 25%;
}
</style>
