<template>
  <div class="phone_app">
    <PhoneTitle :title="LangString('APP_YELLOWPAGES_TITLE')" color="white" backgroundColor="rgb(210, 166, 5)"/>

    <div v-for="(elem, id) in yellows" :key="id" class="post-container" :class="{ select: currentSelect === id }">
      <div class="content-container">
        <span class="author">{{LangString("APP_YELLOWPAGES_AUTHOR_TITLE")}}: {{elem.author}}</span>
        <div class="description-container">
          <span>{{elem.description}}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import PhoneTitle from './../PhoneTitle'
import { mapGetters } from "vuex"
import Modal from '@/components/Modal/index.js'

export default {
  components: { PhoneTitle },
  name: "yellowpages",
  data () {
    return {
      ignoreControls: false,
      currentSelect: 0
    }
  },
  computed: {
    ...mapGetters([
      "LangString",
      "yellows"
    ])
  },
  methods: {
    onDown() {
      if (this.ignoreControls) return
      if (this.currentSelect === this.yellows.length - 1) return
      this.currentSelect++
    },
    onUp() {
      if (this.ignoreControls) return
      if (this.currentSelect === 0) return
      this.currentSelect--
    },
    onEnter() {
      if (this.ignoreControls) return
    },
    onLeft() {
      if (this.ignoreControls) return
    },
    onRight() {
      if (this.ignoreControls) return
      this.ignoreControls = true
      let scelte = [
        { id: 1, title: this.LangString('APP_YELLOWPAGES_NEW_POST'), icons: 'fa-plus' },
      ]
      scelte = [...scelte, { id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' }]
      Modal.CreateModal({ scelte })
      .then(resp => {
        this.ignoreControls = false
        switch (resp.id) {
          case 1:
            break
          case 2:
            break
        }
      })
      .catch(e => { this.ignoreControls = false })
    },
    onBack() {
      if (this.ignoreControls) {
        this.ignoreControls = false
        return
      }
      this.$router.push({ name: 'menu' })
    },
  },
  created () {
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.post-container {
  width: 94%;
  height: auto;
  margin-left: auto;
  margin-right: auto;
  margin-bottom: 10px;
  margin-top: 10px;
  border-radius: 10px;
  background-color: rgb(210, 166, 5);
  transition: all .1s ease-in-out;
}

.post-container.select {
  background-color: rgb(255, 208, 38);
  transition: all .1s ease-in-out;
}

.content-container {
  width: 100%;
  display: flex;
  flex-direction: column;
}

.content-container .author {
  position: relative;
  color: grey;
  padding-left: 10px;
  padding-top: 5px;
  font-weight: bold;
  font-size: 15px;
}

.content-container .description-container {
  position: relative;
  margin-left: auto;
  margin-right: auto;
  margin-top: 10px;
  margin-bottom: 10px;
  background-color: white;
  border-radius: 10px;
  width: 95%;
  padding-top: 10px;
  padding-bottom: 10px;
  padding-left: 8px;
  padding-right: 8px;
}

.description-container span {
  font-size: 16px;
}
</style>
