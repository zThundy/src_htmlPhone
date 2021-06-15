<template>
  <div class="splash">
    <img src="/html/static/img/icons_app/azienda.png" alt="">
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
export default {
  methods: {
    ...mapGetters(['setupUnreadAziendaMessages'])
  },
  created: function () {
    this.$phoneAPI.requestAziendaMessages()
    this.setupUnreadAziendaMessages()
    setTimeout(() => {
      this.$router.push({ name: 'azienda' })
    }, 700)
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
  
  background-color: rgb(255, 180, 89);
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
</style>
