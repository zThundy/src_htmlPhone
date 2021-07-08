<template>
  <div class="splash">
    <img src="/html/static/img/icons_app/calculator.png" alt="">
  </div>
</template>

<script>
export default {
  created: function () {
    setTimeout(() => {
      this.$router.push({ name: 'calculator' })
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
  
  background-color: rgb(82, 158, 206);
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
