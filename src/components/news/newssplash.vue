<template>
  <div class="splash">
    <img src="/html/static/img/icons_app/news.png" alt="">
    
    <custom-toast class="caricamento" @hide="toastHide" :duration="randomWait" :hasMask="false" ref="updating">
      <md-icon class="caricamento-content" name="spinner" size="lg"></md-icon>
    </custom-toast>

  </div>
</template>

<script>
import CustomToast from '@/components/CustomToast'

import { Icon } from 'mand-mobile'
import 'mand-mobile/lib/mand-mobile.css'

export default {
  name: 'news.splash',
  data () {
    return {
      randomWait: Math.floor(Math.random() * (5000 - 8000) + 4000)
    }
  },
  components: {
    CustomToast,
    [Icon.name]: Icon
  },
  computed: { },
  methods: {
    toastHide () {
      this.$router.push({ name: 'news' })
    }
  },
  created: function () {
    this.$phoneAPI.fetchNews()
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

  background-color: rgb(106, 104, 231);
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
