<template>
  <!-- https://una.im/CSSgram/ -->
  <div style="width: 326px; height: 596px;" class="phone_content">
    <link rel="stylesheet" href="https://cssgram-cssgram.netdna-ssl.com/cssgram.min.css">

    <img class='image' :src="tempImage" :class="filters[selectedMessage]">

    <div class="aggiusta_schermo">
      <div class="text-container">{{ LangString('APP_INSTAGRAM_CHOOSE_FILTER') }}</div>

      <div class="image_list">

        <div v-for='(val, key) in filters' :key="key" class="filtersdiv" :class="{ select: Number(key) === Number(selectedMessage) }">

          <div style="text-align: center;">{{ val }}</div>
          <img :class="val" :src="tempImage">

        </div>

      </div>

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
        const elem = this.$el.querySelector('.select')
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
    async onEnter () {
      if (this.ignoreControls) return
      this.ignoreControls = true
      let choix = [
        {id: 1, title: this.LangString('APP_INSTAGRAM_WRITE_CAPTION'), icons: 'fa-pencil-square-o'},
        {id: 2, title: this.LangString('APP_INSTAGRAM_POST_IMAGE'), icons: 'fa-camera'}
      ]
      const resp = await Modal.CreateModal({ choix: choix })
      if (resp.id === 1) {
        Modal.CreateTextModal({ }).then(valueText => {
          if (valueText.text !== '' && valueText.text !== undefined && valueText.text !== null) {
            this.instagramPostImage({didascalia: valueText.text, filter: this.filters[this.selectedMessage], message: this.tempImage, author: this.instagramUsername})
            this.ignoreControls = false
            this.$bus.$emit('instagramHome')
          }
        })
      } else if (resp.id === 2) {
        this.instagramPostImage({didascalia: '', filter: this.filters[this.selectedMessage], message: this.tempImage, author: this.instagramUsername})
        this.ignoreControls = false
        this.$bus.$emit('instagramHome')
      } else {
        this.ignoreControls = false
      }
    }
  },
  created () {
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpBackspace', this.onBack)
    this.$bus.$on('keyUpEnter', this.onEnter)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpBackspace', this.onBack)
    this.$bus.$off('keyUpEnter', this.onEnter)
  }
}
</script>

<style scoped>

.aggiusta_schermo {
  padding-top: 65%;
  overflow: hidden;
}

.image {
  width: 100%;
}

.text-container {
  width: 100%;
  height: 30px;
  padding-top: 4px;
  text-align: center;
  color: white;

  background: -moz-linear-gradient(45deg, #f09433 0%, #e6683c 25%, #dc2743 50%, #cc2366 75%, #bc1888 100%); 
  background: -webkit-linear-gradient(45deg, #f09433 0%,#e6683c 25%,#dc2743 50%,#cc2366 75%,#bc1888 100%); 
  background: linear-gradient(45deg, #f09433 0%,#e6683c 25%,#dc2743 50%,#cc2366 75%,#bc1888 100%); 
  filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#f09433', endColorstr='#bc1888',GradientType=1 );
}

.image_list {
  position: relative;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: row;
  overflow-x: auto;
}

.image_list img {
  flex: 0 0 auto;
  width: 90px;
  height: 90px;
  object-fit: cover;
}

.filtersdiv {
  position: relative;
  background-color: rgba(141, 141, 141, 0.397);
}

.select {
  background-color: rgba(25, 0, 117, 0.397);
  background-image: linear-gradient(to bottom, rgba(140, 85, 145, 0.397) 50%, rgba(201, 0, 219, 0.664) 50%);
  background-size: 100% 200%;
  transition: background-position 0.5s;
  background-position: 0 -100%;
}
</style>
