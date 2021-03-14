<template>
  <div class="splash">
    <img src="/html/static/img/icons_app/email.png" alt="">
    
    <custom-toast class="caricamento" @hide="toastHide" :duration="randomWait" :hasMask="false" ref="updating">
      <md-icon class="caricamento-content" name="spinner" size="lg"></md-icon>
    </custom-toast>

  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import CustomToast from '@/components/CustomToast'

import { Icon } from 'mand-mobile'
import 'mand-mobile/lib/mand-mobile.css'

export default {
  name: 'email.splash',
  data () {
    return {
      randomWait: Math.floor(Math.random() * (5000 - 6000) + 6000)
    }
  },
  components: {
    CustomToast,
    [Icon.name]: Icon
  },
  computed: {
    ...mapGetters(['myEmail'])
  },
  methods: {
    toastHide () {
      if (this.myEmail !== false && this.myEmail !== 'false') {
        if (this.myEmail !== null && this.myEmail !== undefined) {
          this.$phoneAPI.requestSentEmails(this.myEmail)
          this.$phoneAPI.requestEmails()
          this.$router.push({ name: 'email' })
        } else {
          this.$router.push({ name: 'email.register' })
        }
      } else {
        this.$router.push({ name: 'email.register' })
      }
    }
  },
  created: function () {
    this.$phoneAPI.requestMyEmail()
    setTimeout(() => {
      this.$refs.updating.show()
    }, 900)
  }
}
</script>

<style scoped>
.splash {
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;

  background-color: rgb(216, 71, 49);
}

img {
  animation-name: zoom;
  animation-duration: 0.7s;
  animation-fill-mode: forwards;
}

@keyframes zoom {
  from {
    width: 20%;
  }
  to {
    width: 80%;
  }
}

.caricamento {
  top: 20%;
}

.caricamento-content {
  padding-left: 10px;
}
</style>
