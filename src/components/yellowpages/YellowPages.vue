<template>
  <div class="phone_app">
    <PhoneTitle :title="LangString('APP_YELLOWPAGES_TITLE')" color="white" backgroundColor="rgb(210, 166, 5)"/>

    <div class="yellow-container">
      <div v-for="(elem, id) in yellows" :key="id" class="yellow-post-container" :class="{ select: currentSelect === id }">
        <div class="yellow-content-container">
          <span class="author">
            <span v-if="IsPersonalMessage(elem)" class="fas fa-user"></span>
            {{LangString("APP_YELLOWPAGES_AUTHOR_TITLE")}}: {{elem.number}}
          </span>
          <div class="yellow-description-container">
            <span class="yellow-description-content">{{elem.description}}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import PhoneTitle from './../PhoneTitle'
import { mapGetters, mapMutations } from "vuex"
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
      "yellows",
      "myPhoneNumber"
    ])
  },
  methods: {
    ...mapMutations([
      "DELETE_YELLOW_POST"
    ]),
    IsPersonalMessage(m) {
      if (m.number === this.myPhoneNumber) return "fa-plus"
      return ""
    },
    scrollIntoView () {
      this.$nextTick(() => {
        const elem = this.$el.querySelector('.select')
        if (elem !== null) {
          elem.scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' })
        }
      })
    },
    onDown() {
      if (this.ignoreControls) return
      if (this.currentSelect === this.yellows.length - 1) return
      this.currentSelect++
      this.scrollIntoView()
    },
    onUp() {
      if (this.ignoreControls) return
      if (this.currentSelect === 0) return
      this.currentSelect--
      this.scrollIntoView()
    },
    onLeft() {
      if (this.ignoreControls) return
    },
    onRight() {
      if (this.ignoreControls) return
      this.ignoreControls = true
      let scelte = [{ id: 1, title: this.LangString('APP_YELLOWPAGES_NEW_POST'), icons: 'fa-plus' }]
      const yellow = this.yellows[this.currentSelect]
      if (this.yellows.length > 0) {
        if (yellow.number === this.myPhoneNumber) {
          scelte = [...scelte, { id: 2, title: this.LangString('APP_YELLOWPAGES_DELETE_POST'), icons: 'fa-trash', color: 'orange' }]
        }
      }
      scelte = [...scelte, { id: -1, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' }]
      Modal.CreateModal({ scelte })
      .then(resp => {
        this.ignoreControls = false
        switch (resp.id) {
          case 1:
            Modal.CreateTextModal({
              title: this.LangString('TYPE_MESSAGE'),
              color: 'rgb(210, 166, 5)'
            })
            .then(message => {
              this.$phoneAPI.createYellowPost({ message: message.text, author: this.myPhoneNumber })
            })
            break
          case 2:
            this.DELETE_YELLOW_POST(this.currentSelect)
            this.currentSelect--
            this.$phoneAPI.deleteYellowPost({ id: yellow.id })
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
    this.$phoneAPI.requestYellowPosts()
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onRight)
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onRight)
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.yellow-container {
  overflow-y: hidden;
}

.yellow-post-container {
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

.yellow-post-container.select {
  background-color: rgb(255, 208, 38);
  transition: all .1s ease-in-out;
}

.yellow-content-container {
  width: 100%;
  display: flex;
  flex-direction: column;
}

.yellow-content-container .author {
  position: relative;
  color: grey;
  padding-left: 10px;
  padding-top: 5px;
  font-weight: bold;
  font-size: 15px;
}

.yellow-content-container .yellow-description-container {
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

.yellow-description-container .yellow-description-content {
  line-break: normal;
  width: 100%;
  height: auto;
  font-size: 16px;
}
</style>
