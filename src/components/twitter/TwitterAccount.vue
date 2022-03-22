<template>
  <component v-bind:is="state"/>
</template>

<script>
import { mapGetters } from 'vuex'

import MENU from "./twitter_account/TwitterAccountMenu.vue"
import NEW_ACCOUNT from "./twitter_account/TwitterAccountNew.vue"
import NOTIFICATIONS from "./twitter_account/TwitterAccountNotifications.vue"

const STATES = Object.freeze({ MENU, NEW_ACCOUNT, NOTIFICATIONS })

export default {
  name: 'twitter',
  components: {},
  data () {
    return {
      STATES,
      state: STATES.MENU,
      ignoreControls: false
    }
  },
  computed: {
    ...mapGetters([
      'LangString',
    ])
  },
  methods: {
    onUp () {
      if (this.ignoreControls) return
      this.$bus.$emit("twitterOnUp")
    },
    onDown () {
      if (this.ignoreControls) return
      this.$bus.$emit("twitterOnDown")
    },
    onEnter () {
      if (this.ignoreControls) return
      this.$bus.$emit("twitterOnEnter")
    },
    onBack () {
      if (this.ignoreControls) return
      if (this.state !== this.STATES.MENU) {
        this.state = this.STATES.MENU
      } else {
        this.$bus.$emit('twitterHome')
      }
    },
    cancel () {
      this.state = STATES.MENU
    },

    /* NEW FUNCTIONS */
    changingRoute(route) {
      this.state = STATES[route]
    },
    updateIgnoreControls(val) {
      setTimeout(() => { this.ignoreControls = val }, 100)
    }
  },
  created () {
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)

    this.$bus.$on("twitterChangingRoute", this.changingRoute)
    this.$bus.$on("updateTwitterIgnoreControls", this.updateIgnoreControls)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)

    this.$bus.$off("twitterChangingRoute", this.changingRoute)
    this.$bus.$off("updateTwitterIgnoreControls", this.updateIgnoreControls)
  }
}
</script>

<style scoped>
@import url("./twitter_account/style.css");
</style>>
