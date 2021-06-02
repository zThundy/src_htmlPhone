<template>
  <div class="phone_app">
    <PhoneTitle :title="title" :backgroundColor="headerBackground" :showSegnaleSection="showSegnaleSection" v-if="showHeader" @back="back"/>

    <div class="elements">
      <div class="element" v-for='(elem, key) in list' :key="key" v-bind:class="{ select: key === currentSelect }">
          
        <div class="elem-pic" v-bind:style="stylePuce(elem)">{{ formatEmoji(elem.letter || elem[keyDispay][0]) }}</div>
        <div v-if="elem.puce !== undefined && elem.puce !== 0" class="elem-puce">{{ elem.puce }}</div>
        <div v-if="elem.keyDesc === undefined || elem.keyDesc === ''" class="elem-title">{{ formatEmoji(elem[keyDispay]) }}</div>
        <div v-if="elem.keyDesc !== undefined && elem.keyDesc !== ''" class="elem-title-has-desc">
          {{ formatEmoji(elem[keyDispay]) }}
          <div v-if="elem.keyDesc !== undefined && elem.keyDesc !== ''" class="elem-description">{{ formatEmoji(isSMSImage(elem.keyDesc)) }}</div>
        </div>
      
      </div>
    </div>

  </div>
</template>

<script>
import PhoneTitle from './PhoneTitle'
import InfoBare from './InfoBare'
import { mapGetters } from 'vuex'

export default {
  name: 'List',
  components: { PhoneTitle, InfoBare },
  data () {
    return {
      currentSelect: 0
    }
  },
  props: {
    title: {
      type: String,
      default: 'Title'
    },
    showHeader: {
      type: Boolean,
      default: true
    },
    headerBackground: {
      type: String,
      default: 'white'
    },
    showSegnaleSection: {
      type: Boolean,
      default: true
    },
    list: {
      type: Array,
      required: true
    },
    color: {
      type: String,
      default: '#FFFFFF'
    },
    backgroundColor: {
      type: String,
      default: '#4CAF50'
    },
    keyDispay: {
      type: String,
      default: 'display'
    },
    disable: {
      type: Boolean,
      default: false
    },
    titleBackgroundColor: {
      type: String,
      default: '#FFFFFF'
    }
  },
  watch: {
    list: function () {
      this.currentSelect = 0
    }
  },
  computed: {
    ...mapGetters([])
  },
  methods: {
    isSMSImage (mess) {
      var pattern = new RegExp('^(https?:\\/\\/)?' + '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|' + '((\\d{1,3}\\.){3}\\d{1,3}))' + '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*' + '(\\?[;&a-z\\d%_.~+=-]*)?' + '(\\#[-a-z\\d_]*)?$', 'i')
      if (pattern.test(mess)) {
        return 'Immagine'
      }
      return mess
    },
    formatEmoji (message) {
      return this.$phoneAPI.convertEmoji(message)
    },
    styleTitle: function () {
      return {
        color: this.color,
        backgroundColor: this.backgroundColor
      }
    },
    stylePuce (data) {
      data = data || {}
      if (data.icon !== undefined) {
        return {
          backgroundImage: `url(${data.icon})`,
          'background-position': 'center',
          backgroundSize: 'cover',
          color: 'rgba(0,0,0,0)',
          borderRadius: '50%',
          'object-fit': 'fill'
        }
      }
      return {
        color: data.color || this.color,
        backgroundColor: data.backgroundColor || this.backgroundColor,
        borderRadius: '50%'
      }
    },
    scrollIntoView: function () {
      this.$nextTick(() => {
        document.querySelector('.select').scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' })
      })
    },
    onUp: function () {
      if (this.disable === true) return
      this.currentSelect = this.currentSelect === 0 ? this.list.length - 1 : this.currentSelect - 1
      this.scrollIntoView()
    },
    onDown: function () {
      if (this.disable === true) return
      this.currentSelect = this.currentSelect === this.list.length - 1 ? 0 : this.currentSelect + 1
      this.scrollIntoView()
    },
    selectItem (item) {
      this.$emit('select', item)
    },
    optionItem (item) {
      this.$emit('option', item)
    },
    back () {
      this.$emit('back')
    },
    onRight: function () {
      if (this.disable === true) return
      this.$emit('option', this.list[this.currentSelect])
    },
    onEnter: function () {
      if (this.disable === true) return
      this.$emit('select', this.list[this.currentSelect])
    }
  },
  created: function () {
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpEnter', this.onEnter)
  },
  beforeDestroy: function () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpEnter', this.onEnter)
  }
}
</script>

<style scoped>
.list {
  height: 100%;
}

.elements {
  height: 100%;
  width: 100%;
  overflow: hidden;
}

.element {
  overflow: hidden;
  width: 92%;
  height: 60px;
  /* border-bottom: 1px solid #d8d8d8; */
  /* line-height: 60px; */
  margin-top: 12px;

  display: flex;
  align-items: center;
  position: relative;

  font-weight: 300;
  font-size: 18px;
  background-color: rgb(245, 245, 245);
  box-shadow: 0px 0px 8px 0px rgba(0, 0, 0, 0.4);

  margin-left: auto;
  margin-right: auto;
}

.element.select {
  box-shadow: 0px 0px 8px 0px rgba(0, 0, 0, 0.9);
  background-color: rgb(245, 245, 245);
}

.elem-pic {
  margin-left: 12px;
  height: 48px;
  width: 48px;

  text-align: center;
  line-height: 48px;
  position: absolute;
}

.elem-puce {
  background-color: #EE3838;
  color: white;

  height: 16px;
  width: 16px;
  line-height: 18px;

  border-radius: 50%;
  text-align: center;
  font-size: 12px;
  margin: 0px;
  padding: 0px;
  position: absolute;

  top: 4px;
  left: 45px;
  z-index: 6;
}

.elem-title {
  margin-left: 70px;
  font-size: 18px;
  /* font-weight: 200; */
  line-height: 20px;
}

.elem-title-has-desc {
  margin-top: -15px;
  margin-left: 70px;
  line-height: 20px;
  /* font-weight: 200; */
}

.elem-description {
  text-align: left;
  color: grey;
  position: absolute;
  display: block;
  width: 75%;
  left: 75px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;

  font-size: 12.5px;
  /* font-style: italic; */
  /* font-weight: 800; */
}
</style>
