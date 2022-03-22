<template>
  <component v-bind:is="state"/>
</template>

<script>
import { mapGetters } from 'vuex'

import MENU from "./instagram_account/InstagramAccountMenu.vue"
import NEW_ACCOUNT from "./instagram_account/InstagramAccountNew.vue"
import NOTIFICATIONS from "./instagram_account/InstagramAccountNotifications.vue"

const STATES = Object.freeze({ MENU, NEW_ACCOUNT, NOTIFICATIONS })

export default {
  name: 'instagram',
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
      this.$bus.$emit("instagramOnUP")
    },
    onDown () {
      if (this.ignoreControls) return
      this.$bus.$emit("instagramOnDown")
    },
    onEnter () {
      if (this.ignoreControls) return
      this.$bus.$emit("instagramOnEnter")
    },
    onBack () {
      if (this.ignoreControls) return
      if (this.state !== this.STATES.MENU) {
        this.state = this.STATES.MENU
      } else {
        this.$bus.$emit('instagramHome')
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

    this.$bus.$on("instagramChangingRoute", this.changingRoute)
    this.$bus.$on("updateInstagramIgnoreControls", this.updateIgnoreControls)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)

    this.$bus.$off("twitterChangingRoute", this.changingRoute)
    this.$bus.$off("updateInstagramIgnoreControls", this.updateIgnoreControls)
  }
}
</script>

<style scoped>
@import url("./instagram_account/style.css");
</style>>
