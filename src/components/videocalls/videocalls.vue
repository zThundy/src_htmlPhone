<template>
  <div class="videocalls">
    <list :list='contacts' :disable="ignoreControls" :titleColor="'white'" :color="'white'" :headerBackground="'rgb(70, 0, 115)'" :backgroundColor="'rgb(70, 0, 115)'" :title="LangString('APP_VIDEOCALLS_TITLE')" @option='showOptions'></list>

    <div class="videocalls-dot">
      <i class="fa fa-video"></i>
    </div>
  </div>
</template>

<script>
import PhoneTitle from './../PhoneTitle'
import List from './../List.vue'
import { mapGetters } from 'vuex'
import Modal from '@/components/Modal/index.js'

export default {
  name: 'videocalls',
  components: { PhoneTitle, List },
  data () {
    return {
      ignoreControls: false
    }
  },
  computed: {
    ...mapGetters(['LangString', 'contacts', "myPhoneNumber"])
  },
  methods: {
    onBack () {
      if (this.ignoreControls) return
      this.$router.push({ name: 'menu' })
    },
    showOptions(contact) {
      this.ignoreControls = true
      Modal.CreateModal({ scelte: [
        { id: 1, title: this.LangString('APP_VIDEOCALLS_CALL'), icons: 'fa-phone', color: 'green' },
        { id: 2, title: this.LangString('CANCEL'), icons: 'fa-undo', color: 'red' }
      ] })
      .then(response => {
        switch(response.id) {
          case 1:
            this.$router.push({ name: 'videocalls.active', params: { contact } })
            break
          case 2:
            break
        }
        this.ignoreControls = false
      })
      .catch(e => { this.ignoreControls = false })
    },
    // dev func
    onEnter() {
    }
  },
  created () {
    // start dev func
    this.$bus.$on('keyUpEnter', this.onEnter)
    // end dev func
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  beforeDestroy () {
    // start dev func
    this.$bus.$off('keyUpEnter', this.onEnter)
    // end dev func
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.videocalls {
  position: relative;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
}

.videocalls-dot {
  position: fixed;
  width: 60px;
  height: 60px;
  background-color: rgb(70, 0, 115);
  bottom: 21%;
  right: 31%;
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.6);
  border-radius: 50%;
}

.videocalls-dot i {
  color: white;
  padding-top: 16px;
  font-size: 28px;
  display: flex;
  justify-content: center;
}
</style>
