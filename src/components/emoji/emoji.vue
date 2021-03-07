<template>
  <div style="width: 100%; height: 100%;" class="phone_app">
    <PhoneTitle :title="LangString('APP_EMOJI_TITLE')" :color="'black'" backgroundColor="rgba(200, 200, 200, .8)"/>

    <div class="emojis-container">
      <div v-for="(el, key) in emojis" :key="key" :class="{ selected: currentSelect == key }" class="emoji-div">
        <span>{{ el.emoji }}</span>
        <span>:{{ el.name }}:</span>
      </div>
    </div>

  </div>
</template>

<script>
import PhoneTitle from './../PhoneTitle'
import { mapGetters } from 'vuex'

export default {
  name: 'azienda-screen',
  components: { PhoneTitle },
  data () {
    return {
      computedEmojis: [],
      currentSelect: -1
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
      this.$router.push({ name: 'menu' })
    },
    onUp () {
      if (this.currentSelect === -1) {
        this.currentSelect = this.emojis.length - 1
        this.scrollIntoView()
        return
      }
      this.currentSelect = this.currentSelect - 1
      this.scrollIntoView()
    },
    onDown () {
      if (this.currentSelect === this.emojis.length - 1) {
        this.currentSelect = -1
        this.scrollIntoView()
      }
      this.currentSelect = this.currentSelect + 1
      this.scrollIntoView()
    }
  },
  created () {
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpArrowDown', this.onDown)
    // this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  mounted () {
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpArrowDown', this.onDown)
    // this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.emojis-container {
  height: 100%;
  width: 100%;
  overflow: hidden;
}

.emoji-div {
  height: 40px;
  width: 100%;
  margin-top: 5px;
}

.emoji-div span {
  font-size: 25px;
  margin-left: 5px;
}

.selected {
  background-color: rgb(255, 209, 140);
}
</style>
