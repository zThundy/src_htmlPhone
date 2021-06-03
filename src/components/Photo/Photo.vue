<template>
  <div class="general-container">
    <div class="picture-snap-cyrcle-contaniner">
      <div class="picture-snap-cyrcle-ext"></div>
      <div class="picture-snap-cyrcle-int"></div>
    </div>
  </div>
</template>

<script>
// import { mapActions } from 'vuex'

export default {
  data () {
    return {
      ignoreControls: false
    }
  },
  methods: {
    // ...mapActions(['addPhoto'])
    async onEnter () {
      const resp = await this.$phoneAPI.takePhoto()
      // this.addPhoto({ link: resp.url })
      if (resp) {
        this.$router.push({ name: 'galleria.splash', params: resp })
      }
    },
    onBack () {
      if (this.ignoreControls) {
        this.ignoreControls = false
        return
      }
      this.$router.push({ name: 'menu' })
    }
  },
  async created () {
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.general-container {
  background-color: black;
  width: 100%;
  height: 100%;
}

.picture-snap-cyrcle-contaniner {
  position: relative;
  top: 495px;
  width: 100%;
  height: 15%;
}

.picture-snap-cyrcle-ext {
  margin-left: auto;
  margin-right: auto;

  height: 90px;
  width: 90px;
  background-color: white;
  border-radius: 50px;
}

.picture-snap-cyrcle-int {
  position: absolute;

  bottom: 5px;
  left: 125px;

  height: 80px;
  width: 80px;
  background-color: white;
  border-radius: 50px;

  border: 3px solid black;
}
</style>
