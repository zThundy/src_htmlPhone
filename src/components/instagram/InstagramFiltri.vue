<template>
  <!-- https://una.im/CSSgram/ -->
  <div class="filters-screen-container">
    <!-- <link rel="stylesheet" href="/assets/css/cssgram.css"> -->
    <!-- <link rel="stylesheet" href="https://cssgram-cssgram.netdna-ssl.com/cssgram.min.css"> -->

    <div class="central-image-div">
      <img class='image' :src="tempImage" :class="filters[selectedMessage]">
    </div>

    <div class="filters-images-container">
      <!-- <div class="text-container">{{ LangString('APP_INSTAGRAM_CHOOSE_FILTER') }}</div> -->

      <button
        v-for='(val, key) in filters'
        :key="key"
        :class="[{ selected: Number(key) === Number(selectedMessage)}, val]"
        :style="{ backgroundImage: 'url(' + tempImage + ')' }"
      >
        <!-- <img class="single-filter-image" :class="val" :src="tempImage"> -->
        {{ val }}
      </button>

    </div>

  </div>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'
import Modal from '@/components/Modal/index.js'

export default {
  components: {},
  data () {
    return {
      selectedMessage: 0,
      ignoreControls: false,
      filters: {
        0: 'Originale',
        1: '_1977',
        2: 'aden',
        3: 'brannan',
        4: 'brooklyn',
        5: 'clarendon',
        6: 'earlybird',
        7: 'gingham',
        8: 'hudson',
        9: 'inkwell',
        10: 'kelvin',
        11: 'lark',
        12: 'lofi',
        13: 'maven',
        14: 'mayfair',
        15: 'moon',
        16: 'nashville',
        17: 'perpetua',
        18: 'reyes',
        19: 'rise',
        20: 'slumber',
        21: 'stinson',
        22: 'toaster',
        23: 'valencia',
        24: 'walden',
        25: 'willow',
        26: 'xpro2'
      }
    }
  },
  computed: {
    ...mapGetters(['LangString', 'tempImage', 'instagramUsername', 'instagramPassword'])
  },
  watch: {
  },
  methods: {
    ...mapActions(['instagramPostImage']),
    scrollIntoView () {
      this.$nextTick(() => {
        const elem = this.$el.querySelector('.selected')
        if (elem !== null) {
          elem.scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' })
        }
      })
    },
    onLeft () {
      if (this.ignoreControls) return
      this.selectedMessage = this.selectedMessage === 0 ? 0 : this.selectedMessage - 1
      this.scrollIntoView()
    },
    onRight () {
      if (this.ignoreControls) return
      // il 26 in questa funzione sarebbe il massimo di filtri: non ho idea
      // di perche non prenda this.filters.length
      this.selectedMessage = this.selectedMessage === 26 ? this.selectedMessage : this.selectedMessage + 1
      this.scrollIntoView()
    },
    onBack () {
      if (this.ignoreControls) return
      this.$bus.$emit('instagramHome')
    },
    onUp () {
      if (this.ignoreControls) return
      // il 26 in questa funzione sarebbe il massimo di filtri: non ho idea
      // di perche non prenda this.filters.length
      this.selectedMessage = (this.selectedMessage < 3) ? this.selectedMessage : this.selectedMessage - 3
      this.scrollIntoView()
    },
    onDown () {
      if (this.ignoreControls) return
      // il 26 in questa funzione sarebbe il massimo di filtri: non ho idea
      // di perche non prenda this.filters.length
      this.selectedMessage = (this.selectedMessage > 23) ? this.selectedMessage : this.selectedMessage + 3
      this.scrollIntoView()
    },
    onEnter () {
      if (this.ignoreControls) return
      this.ignoreControls = true
      Modal.CreateModal({ scelte: [
        { id: 1, title: this.LangString('APP_INSTAGRAM_WRITE_CAPTION'), icons: 'fa-pencil-alt' },
        { id: 2, title: this.LangString('APP_INSTAGRAM_POST_IMAGE'), icons: 'fa-camera' }
      ] }).then(resp => {
        switch(resp.id) {
          case 1:
            Modal.CreateTextModal({
              title: this.LangString('TYPE_MESSAGE'),
              limit: 255
            })
            .then(resp => {
              if (resp.text !== '' && resp.text !== undefined && resp.text !== null) {
                this.instagramPostImage({didascalia: resp.text, filter: this.filters[this.selectedMessage], message: this.tempImage, author: this.instagramUsername})
                this.$bus.$emit('instagramHome')
              }
              this.ignoreControls = false
            })
            .catch(e => { this.ignoreControls = false })
            break
          case 2:
            this.instagramPostImage({didascalia: '', filter: this.filters[this.selectedMessage], message: this.tempImage, author: this.instagramUsername})
            this.ignoreControls = false
            this.$bus.$emit('instagramHome')
            break
        }
      })
      .catch(e => { this.ignoreControls = false })
    }
  },
  created () {
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpBackspace', this.onBack)
    this.$bus.$on('keyUpEnter', this.onEnter)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpBackspace', this.onBack)
    this.$bus.$off('keyUpEnter', this.onEnter)
  }
}
</script>

<style scoped>
.filters-screen-container {
  height: 100%;
  width: 100%;
  overflow: hidden;

  display: flex;
  flex-direction: column;
  background-color: rgba(50, 50, 50, 0.1);
}

/* IMMAGINE CENTRALE */

.central-image-div {
  position: fixed;
  width: 330px;
  height: 188px;

  border-bottom: 2px solid black;
}

.central-image-div img {
  width: 100%;
}

/* SELEZIONE FILTRO */

.filters-images-container {
  overflow: hidden;
  position: inherit;

  margin-top: 190px;
  display: flex;
  width: 330px;
  height: 420px;
  align-items: flex-start;
  align-content: flex-start;

  margin-left: auto;
  margin-right: auto;

  flex-flow: row;
  flex-wrap: wrap;

  border-radius: 20px;
}

button {
  margin-top: 10px;
  display: flex;
  width: 30%;
  height: 50px;
  align-items: flex-start;
  align-content: flex-start;

  margin-left: auto;
  margin-right: auto;

  flex-flow: row;
  flex-wrap: wrap;

  border: none;
  align-content: center;
  border-radius: 10px;
  border: 1px solid black;
}

.selected {
  border: 3px solid black;
}
</style>
