<template>
  <div style="width: 100%; height: 100%;" class="phone_app">
    <PhoneTitle :title="LangString('APP_EMOJI_TITLE')" :color="'black'" backgroundColor="rgba(200, 200, 200, .8)"/>

    <div v-if="show" class="emoji-info-container">
      <div class="emoji-info">
        <div class="emoji-info-label">
          <span>{{ show.emoji }}</span>
        </div>
        <div class="emoji-info-content">
          <h1>{{ show.name }}</h1>
          <h2>{{ LangString("APP_EMOJI_DESCRIPTION") }}</h2>
          <h1 style="font-size: 13px">:{{ show.name }}:</h1>
        </div>
      </div>
    </div>

    <div class="content-container">
      <div class="emojis-container">
        <div v-for="(el, key) in emojis" :key="key" :class="{ selected: currentSelect == key }" class="emoji-div">
          <span>{{ el.emoji }}</span>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
import PhoneTitle from './../PhoneTitle'
import { mapGetters } from 'vuex'

const columns = 7

export default {
  name: 'azienda-screen',
  components: { PhoneTitle },
  data () {
    return {
      computedEmojis: [],
      currentSelect: 0,
      show: null
    }
  },
  computed: {
    ...mapGetters(['LangString']),
    emojis () {
      let c = 0
      let e = this.$phoneAPI.getEmojis()
      for (var i in e) {
        this.computedEmojis[c] = { name: i, emoji: e[i] }
        c = c + 1
      }
      return this.computedEmojis
    }
  },
  watch: {
  },
  methods: {
    scrollIntoView () {
      this.$nextTick(() => {
        const elem = this.$el.querySelector('.selected')
        if (elem !== null) {
          elem.scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' })
        }
      })
    },
    onBack () {
      if (this.show) {
        this.show = null
        return
      }
      this.$router.push({ name: 'menu' })
    },
    onEnter () {
      if (this.show) return
      // console.log('todo show shit')
      // console.log(this.emojis[this.currentSelect])
      this.show = this.emojis[this.currentSelect]
    },
    onUp () {
      if (this.show) return
      if (this.currentSelect < columns) {
        this.currentSelect = this.currentSelect + this.emojis.length
      }
      this.currentSelect = this.currentSelect - columns
      this.scrollIntoView()
    },
    onDown () {
      if (this.show) return
      if (this.currentSelect > (this.emojis.length - 1) - columns) {
        this.currentSelect = (this.currentSelect - this.emojis.length) + columns
        this.scrollIntoView()
        return
      }
      this.currentSelect = this.currentSelect + columns
      this.scrollIntoView()
    },
    onLeft () {
      if (this.show) return
      if (this.currentSelect === 0) {
        this.currentSelect = this.emojis.length - 1
        this.scrollIntoView()
        return
      }
      this.currentSelect = this.currentSelect - 1
      this.scrollIntoView()
    },
    onRight () {
      if (this.show) return
      if (this.currentSelect === this.emojis.length - 1) {
        this.currentSelect = 0
        this.scrollIntoView()
        return
      }
      this.currentSelect = this.currentSelect + 1
    }
  },
  created () {
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  mounted () {
  },
  beforeDestroy () {
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.content-container {
  height: 88%;
  width: 100%;
  overflow: hidden;
}

.emojis-container {
  height: 100%;
  width: 95%;
  overflow: hidden;

  display: flex;
  flex-direction: row;

  flex-flow: row;
  flex-wrap: wrap;
  text-align: center;

  margin: auto;
}

.emoji-div {
  height: 40px;
  width: 40px;
  margin-top: 5px;
  
  margin-left: auto;
  margin-right: auto;
  padding-top: 1px;
}

.emoji-div span {
  font-size: 25px;
  position: relative;
}

.selected {
  transition: 0.1s all ease-in;
  border-radius: 10px;
  background-color: rgb(255, 209, 140);
}

.selected span {
  transition: 0.1s all ease-in;
  font-size: 28px;
}

.emoji-info-container {
  width: 100%;
  height: auto;
  position: absolute;
  margin-top: 80%;
  z-index: 99;
}

.emoji-info {
  width: 270px;
  height: 200px;
  margin-left: auto;
  margin-right: auto;
  background-color: white;
  border: 1px solid black;
  border-radius: 20px;

  display: flex;
  flex-direction: row;
}

.emoji-info-container {
  animation-name: down;
  animation-duration: 0.2s;
  animation-fill-mode: forwards;
  /*transition: all 0.5s ease-in-out;*/
}

@keyframes down {
  from {
    transform: translateY(-50px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.emoji-info-label {
  width: 50%;
  height: 100%;
  text-align: center;
  padding-top: 30px;
}

.emoji-info-label span {
  width: 50%;
  height: 100%;
  font-size: 90px;
  /* margin: auto; */
}

.emoji-info-content {
  width: 50%;
  height: 100%;
  
  text-align: center;
  padding-top: 30px;
}

.emoji-info-content h1 {
  font-size: 20px;
  width: 90%;
  font-weight: bolder;
}

.emoji-info-content h2 {
  padding-top: 20px;
  font-size: 12px;
  width: 90%;
}
</style>
