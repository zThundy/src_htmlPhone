<template>
  <div class="phone_app">
    <PhoneTitle :title="LangString('APP_CALCULATOR_TITLE')" :backgroundColor="'rgb(120, 205, 255)'" />

    <div class="calculator-container">
      <div class="input-container">
        <input class="result-label" type="text" :value="calcLabel" disabled>
        <input class="fast-result" type="text" :value="computedResult" disabled>
      </div>

      <div class="buttons-container">
        <div v-for="(elem, id) in buttons" :key="id" class="number-container" :style="{ 'background-color': elem.background }" :class="{ select: currentSelect === id }">
          <span class="number-span" :style="{ color: elem.color }">{{ elem.label }}</span>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
import PhoneTitle from './../PhoneTitle'
import BigEval from 'bigeval'
const Obj = new BigEval()

import { mapGetters } from 'vuex'

export default {
  name: 'calculator',
  components: { PhoneTitle },
  data () {
    return {
      buttons: [
        {label: 'C', color: 'red'},
        {label: '^'},
        {label: '%'},
        {label: '÷'},
        {label: '1', number: true},
        {label: '2', number: true},
        {label: '3', number: true},
        {label: '+'},
        {label: '4', number: true},
        {label: '5', number: true},
        {label: '6', number: true},
        {label: '-'},
        {label: '7', number: true},
        {label: '8', number: true},
        {label: '9', number: true},
        {label: 'x'},
        {label: '.'},
        {label: '0', number: true},
        {label: '00', number: true},
        {label: '=', color: 'white', background: 'rgb(102, 173, 217)'}
      ],
      calcLabel: '',
      calcValue: '',
      replaceString: '',
      currentSelect: 0,
      currentButton: null
    }
  },
  computed: {
    ...mapGetters(['LangString']),
    computedResult () {
      try {
        this.calcValue = this.calcLabel
        this.calcValue = this.calcValue.replaceAll('^', '**')
        this.calcValue = this.calcValue.replaceAll('%', '/100')
        this.calcValue = this.calcValue.replaceAll('÷', '/')
        this.calcValue = this.calcValue.replaceAll('x', '*')
        return Obj.execute(this.calcValue)
      } catch (e) { }
    }
  },
  methods: {
    onBackspace () {
      // console.log(this.calcLabel.length)
      if (this.calcLabel.length > 0 /* || this.calcLabel.length === undefined */) {
        this.calcLabel = this.calcLabel.slice(0, -1)
        return
      }
      this.$router.push({ name: 'menu' })
    },
    onRight () {
      if (this.currentSelect === this.buttons.length - 1) return
      this.currentSelect += 1
      this.currentButton = this.buttons[this.currentSelect]
    },
    onLeft () {
      if (this.currentSelect === 0) return
      this.currentSelect -= 1
      this.currentButton = this.buttons[this.currentSelect]
    },
    onDown () {
      if (this.currentSelect > 15) return
      this.currentSelect += 4
      this.currentButton = this.buttons[this.currentSelect]
    },
    onUp () {
      if (this.currentSelect < 4) return
      this.currentSelect -= 4
      this.currentButton = this.buttons[this.currentSelect]
    },
    onEnter () {
      // console.log(this.currentButton)
      let curr = this.currentButton
      if (curr.label === '=') {
        this.calcLabel = this.computedResult || ''
        this.calcLabel = String(this.calcLabel)
        this.calcValue = ''
        return
      }
      if (curr.label === 'C') {
        this.calcValue = ''
        this.calcLabel = ''
        return
      }
      if (this.calcLabel.length > 15) return
      // console.log(isNaN(Number(curr.label)), isNaN(Number(this.calcLabel[this.calcLabel.length - 1])))
      // console.log(curr.label, this.calcLabel[this.calcLabel.length - 1])
      if (isNaN(Number(curr.label)) && isNaN(Number(this.calcLabel[this.calcLabel.length - 1])) /* && this.calcLabel[this.calcLabel.length - 1] !== undefined */) {
        this.calcLabel = String(this.calcLabel)
        this.calcLabel = this.calcLabel.substr(0, this.calcLabel.length - 1) + curr.label + this.calcLabel.substr(this.calcLabel.length - 1 + curr.label.length)
      } else {
        this.calcLabel += String(curr.label)
      }
    }
  },
  created () {
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
  }
}
</script>

<style scoped>
.calculator-container {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.input-container {
  width: 100%;
  height: 100%;
  position: relative;
  text-align: center;
}

.select {
  filter: brightness(80%);
  background-color: rgba(128, 128, 128, 0.2);
}

.result-label {
  position: relative;
  width: 100%;
  height: 100px;
  outline: none;
  border: none;
  text-align: right;
  padding-right: 15px;
  font-size: 25px;
  color: black;
}

.fast-result {
  position: relative;
  width: 100%;
  height: 100px;
  outline: none;
  border: none;
  text-align: right;
  padding-right: 15px;
  font-size: 20px;
  color: grey;
}

.buttons-container {
  position: relative;
  width: 100%;
  height: 100%;
  display: flex;
  flex-flow: row;
  flex-wrap: wrap;
}

.number-container {
  position: relative;
  width: 82.5px;
  height: 82.5px;
  text-align: center;
  /* margin-top: auto; */
  /* margin-bottom: auto; */
  border-top: .5px solid rgb(195, 195, 195);
  border-left: .5px solid rgb(195, 195, 195);
}

.number-span {
  position: relative;
  font-size: 25px;
  top: 25px;
  color: grey
}
</style>
